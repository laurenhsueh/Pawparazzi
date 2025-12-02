//
//  CatStore.swift
//  Pawparazzi
//
//  Created by ChatGPT on 12/2/25.
//

import Foundation
import SwiftUI

@MainActor
final class CatStore: ObservableObject {
    static let shared = CatStore()

    @Published private(set) var cats: [CatModel] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var isPosting: Bool = false
    @Published var postingError: String?
    @Published var searchResults: [CatModel] = []
    @Published var isSearching: Bool = false
    @Published var searchError: String?

    // Collections UI state preserved from the legacy manager
    @Published var userCollections: [String: [String]] = [
        "Favorites": [],
        "Cute Cats": [],
        "Funny Cats": []
    ]
    @Published var showingSaveToCollection: Bool = false
    @Published var selectedPhotoToSave: String?

    private let api: PawparazziAPI
    private var nextCursor: String?
    private var hasMore: Bool = true
    private var searchCursor: String?
    private var searchHasMore: Bool = false
    private var currentSearchTags: [String] = []
    private var currentSearchMode: String = "any"
    private var searchTask: Task<Void, Never>?

    init(api: PawparazziAPI = .shared) {
        self.api = api
    }

    deinit {
        searchTask?.cancel()
    }

    // MARK: - Public API

    func refresh() async {
        nextCursor = nil
        hasMore = true
        await loadCats(reset: true)
    }

    func loadMoreIfNeeded(currentCat cat: CatModel?) async {
        guard let cat = cat, hasMore else { return }
        let thresholdIndex = cats.index(cats.endIndex, offsetBy: -5, limitedBy: cats.startIndex) ?? cats.startIndex
        if cats.firstIndex(where: { $0.id == cat.id }) == thresholdIndex {
            await loadCats(reset: false)
        }
    }

    func loadMoreSearchResultsIfNeeded(currentCat cat: CatModel?) async {
        guard
            let cat = cat,
            searchHasMore,
            !isSearching
        else { return }

        let thresholdIndex = searchResults.index(searchResults.endIndex, offsetBy: -5, limitedBy: searchResults.startIndex) ?? searchResults.startIndex
        if searchResults.firstIndex(where: { $0.id == cat.id }) == thresholdIndex {
            await fetchMoreSearchResults()
        }
    }

    func postCat(
        name: String,
        description: String?,
        tags: [String],
        location: CatLocation?,
        imageBase64: String
    ) async {
        guard !isPosting else { return }
        isPosting = true
        postingError = nil
        defer { isPosting = false }

        do {
            let response = try await api.postCat(
                name: name,
                description: description,
                tags: tags,
                location: location,
                imageBase64: imageBase64
            )
            cats.insert(response.cat, at: 0)
        } catch {
            postingError = error.localizedDescription
        }
    }

    func likeCat(_ cat: CatModel) async {
        guard let index = cats.firstIndex(where: { $0.id == cat.id }) else { return }
        let original = cats[index]
        applyOptimisticLike(at: index, liked: true)

        do {
            let response = try await api.likeCat(id: cat.id)
            updateLikes(for: response.catId, likes: response.likes, liked: response.liked)
        } catch {
            restore(cat: original)
            errorMessage = error.localizedDescription
        }
    }

    func removeLike(_ cat: CatModel) async {
        guard let index = cats.firstIndex(where: { $0.id == cat.id }) else { return }
        let original = cats[index]
        applyOptimisticLike(at: index, liked: false)

        do {
            let response = try await api.removeLike(id: cat.id)
            updateLikes(for: response.catId, likes: response.likes, liked: response.liked)
        } catch {
            restore(cat: original)
            errorMessage = error.localizedDescription
        }
    }

    func savePhoto(_ photoURL: String?, to collection: String) {
        guard let photoURL else { return }
        if userCollections[collection] != nil {
            userCollections[collection]?.append(photoURL)
        } else {
            userCollections[collection] = [photoURL]
        }
    }

    func clearSearchResults() {
        searchTask?.cancel()
        searchResults = []
        searchError = nil
        searchCursor = nil
        searchHasMore = false
        currentSearchTags = []
        isSearching = false
    }

    func searchCats(tags: [String], mode: String = "any") {
        let sanitized = sanitize(tags: tags)
        searchTask?.cancel()

        guard !sanitized.isEmpty else {
            clearSearchResults()
            return
        }

        isSearching = true
        searchError = nil
        searchTask = Task { [weak self] in
            do {
                try await Task.sleep(nanoseconds: 300_000_000)
                try Task.checkCancellation()
                await self?.performSearch(tags: sanitized, mode: mode)
            } catch {
                // Task was cancelled by a newer search request or sleep failed
            }
        }
    }

    func searchCatsImmediately(tags: [String], mode: String = "any") async {
        let sanitized = sanitize(tags: tags)
        searchTask?.cancel()

        guard !sanitized.isEmpty else {
            clearSearchResults()
            return
        }

        isSearching = true
        searchError = nil
        await performSearch(tags: sanitized, mode: mode)
    }

    // MARK: - Private

    private func loadCats(reset: Bool) async {
        guard !isLoading, hasMore || reset else { return }
        isLoading = true
        defer { isLoading = false }

        do {
            let response = try await api.listCats(
                limit: 20,
                cursor: reset ? nil : nextCursor,
                username: nil
            )
            nextCursor = response.nextCursor
            hasMore = response.nextCursor != nil
            errorMessage = nil

            if reset {
                cats = response.cats
            } else {
                cats.append(contentsOf: response.cats)
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func fetchMoreSearchResults() async {
        guard searchHasMore else { return }
        isSearching = true
        defer { isSearching = false }

        do {
            let response = try await api.searchCats(
                tags: currentSearchTags,
                mode: currentSearchMode,
                limit: 20,
                cursor: searchCursor
            )
            searchResults.append(contentsOf: response.cats)
            searchCursor = response.nextCursor
            searchHasMore = response.nextCursor != nil
            searchError = nil
        } catch {
            searchError = error.localizedDescription
        }
    }

    private func performSearch(tags: [String], mode: String) async {
        currentSearchTags = tags
        currentSearchMode = mode
        searchCursor = nil
        searchHasMore = true

        defer { isSearching = false }

        do {
            let response = try await api.searchCats(
                tags: tags,
                mode: mode,
                limit: 20,
                cursor: nil
            )
            searchResults = response.cats
            searchCursor = response.nextCursor
            searchHasMore = response.nextCursor != nil
            searchError = nil
        } catch {
            searchResults = []
            searchError = error.localizedDescription
        }
    }

    private func sanitize(tags: [String]) -> [String] {
        var seen = Set<String>()
        var result: [String] = []
        for raw in tags {
            let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmed.isEmpty else { continue }
            if !seen.contains(trimmed.lowercased()) {
                seen.insert(trimmed.lowercased())
                result.append(trimmed)
            }
        }
        return result
    }

    private func applyOptimisticLike(at index: Int, liked: Bool) {
        guard cats.indices.contains(index) else { return }
        var updated = cats[index]
        if liked {
            updated.likes += 1
        } else {
            updated.likes = max(0, updated.likes - 1)
        }
        updated.isLiked = liked
        cats[index] = updated
        synchronizeSearchResult(with: updated)
    }

    private func restore(cat: CatModel) {
        if let index = cats.firstIndex(where: { $0.id == cat.id }) {
            cats[index] = cat
        }
        synchronizeSearchResult(with: cat)
    }

    private func updateLikes(for id: UUID, likes: Int, liked: Bool?) {
        if let index = cats.firstIndex(where: { $0.id == id }) {
            cats[index].likes = likes
            cats[index].isLiked = liked
        }
        if let index = searchResults.firstIndex(where: { $0.id == id }) {
            searchResults[index].likes = likes
            searchResults[index].isLiked = liked
        }
    }

    private func synchronizeSearchResult(with cat: CatModel) {
        if let index = searchResults.firstIndex(where: { $0.id == cat.id }) {
            searchResults[index] = cat
        }
    }
}

