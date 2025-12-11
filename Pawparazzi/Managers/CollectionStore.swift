//
//  CollectionStore.swift
//  Pawparazzi
//
//  Created by ChatGPT on 12/11/25.
//

import Foundation

@MainActor
final class CollectionStore: ObservableObject {
    @Published private(set) var collection: CollectionModel?
    @Published private(set) var cats: [CatModel] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    private let api: PawparazziAPI
    private var cachedCollectionId: UUID?
    private var nextCursor: String?
    private var hasMore: Bool = true
    private var loadTask: Task<Void, Never>?

    init(api: PawparazziAPI = .shared) {
        self.api = api
    }

    func refresh(id: UUID) async {
        guard shouldReset(for: id) else {
            await loadCollection(id: id, reset: true)
            return
        }
        cachedCollectionId = id
        nextCursor = nil
        hasMore = true
        await loadCollection(id: id, reset: true)
    }

    func loadMoreIfNeeded(currentCat cat: CatModel?, collectionId: UUID) async {
        guard let cat else { return }
        let thresholdIndex = cats.index(cats.endIndex, offsetBy: -5, limitedBy: cats.startIndex) ?? cats.startIndex
        if cats.firstIndex(where: { $0.id == cat.id }) == thresholdIndex {
            await loadCollection(id: collectionId, reset: false)
        }
    }

    private func shouldReset(for id: UUID) -> Bool {
        cachedCollectionId.map { $0 != id } ?? true
    }

    private func loadCollection(id: UUID, reset: Bool) async {
        if let loadTask {
            await loadTask.value
            if !reset { return }
        }

        let task = Task { [weak self] in
            guard let self else { return }
            await self.performLoadCollection(id: id, reset: reset)
        }

        loadTask = task
        await task.value
        loadTask = nil
    }

    private func performLoadCollection(id: UUID, reset: Bool) async {
        guard !isLoading, hasMore || reset else { return }
        isLoading = true
        defer { isLoading = false }

        do {
            cachedCollectionId = id
            let response = try await api.getCollection(
                id: id,
                limit: 30,
                cursor: reset ? nil : nextCursor
            )
            collection = response.collection
            nextCursor = response.nextCursor
            hasMore = response.nextCursor != nil
            errorMessage = nil

            if reset {
                cats = response.cats
            } else {
                cats.append(contentsOf: response.cats)
            }
        } catch is CancellationError {
            // ignore task cancellation
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
