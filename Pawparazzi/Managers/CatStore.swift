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

    init(api: PawparazziAPI = .shared) {
        self.api = api
    }

    // MARK: - Public API

    func refresh() async {
        nextCursor = nil
        hasMore = true
        await loadCats(reset: true)
    }

    func loadMoreIfNeeded(currentCat cat: CatModel?) async {
        guard let cat = cat else { return }
        let thresholdIndex = cats.index(cats.endIndex, offsetBy: -5, limitedBy: cats.startIndex) ?? cats.startIndex
        if cats.firstIndex(where: { $0.id == cat.id }) == thresholdIndex {
            await loadCats(reset: false)
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
        do {
            let response = try await api.likeCat(id: cat.id)
            updateLikes(for: cat.id, likes: response.likes)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func removeLike(_ cat: CatModel) async {
        do {
            let response = try await api.removeLike(id: cat.id)
            updateLikes(for: cat.id, likes: response.likes)
        } catch {
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

    private func updateLikes(for id: UUID, likes: Int) {
        guard let index = cats.firstIndex(where: { $0.id == id }) else { return }
        cats[index].likes = likes
    }
}

