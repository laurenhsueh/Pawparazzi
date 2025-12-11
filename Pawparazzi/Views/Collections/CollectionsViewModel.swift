import Foundation
import SwiftUI

struct CollectionPreview: Identifiable, Hashable {
    let id: UUID
    let name: String
    let count: Int
    let previewURLs: [String]
}

enum CollectionCreationError: LocalizedError {
    case emptyName
    
    var errorDescription: String? {
        "Please enter a collection name."
    }
}

@MainActor
final class CollectionsViewModel: ObservableObject {
    @Published private(set) var collections: [CollectionPreview] = []
    @Published var isLoading: Bool = false
    @Published var isCreating: Bool = false
    @Published var errorMessage: String?
    
    private let api: PawparazziAPI
    private var lastUsername: String?
    private var loadTask: Task<Void, Never>?
    
    init(api: PawparazziAPI = .shared) {
        self.api = api
    }
    
    func loadCollections(for username: String, force: Bool = false) async {
        if let loadTask {
            await loadTask.value
            if !force && username == lastUsername && !collections.isEmpty {
                return
            }
        }
        
        let task = Task { [weak self] in
            guard let self else { return }
            await self.performLoadCollections(for: username, force: force)
        }
        
        loadTask = task
        await task.value
        loadTask = nil
    }
    
    private func performLoadCollections(for username: String, force: Bool) async {
        guard force || username != lastUsername || collections.isEmpty else { return }
        lastUsername = username
        
        guard !isLoading else { return }
        isLoading = true
        defer { isLoading = false }
        
        do {
            let listResponse = try await api.listCollections(username: username, limit: 10)
            errorMessage = nil
            
            let order = Dictionary(uniqueKeysWithValues: listResponse.collections.enumerated().map { ($0.element.id, $0.offset) })
            let previews = try await withThrowingTaskGroup(of: CollectionPreview.self) { group in
                for collection in listResponse.collections {
                    group.addTask { [api] in
                        do {
                            let detail = try await api.getCollection(
                                id: collection.id,
                                limit: 4,
                                cursor: nil,
                                includeAuthContext: true
                            )
                            let urls = detail.cats.compactMap { $0.imageUrl }
                            return CollectionPreview(
                                id: detail.collection.id,
                                name: detail.collection.name,
                                count: detail.collection.catCount,
                                previewURLs: urls
                            )
                        } catch {
                            // Keep the collection visible even if previews fail
                            return CollectionPreview(
                                id: collection.id,
                                name: collection.name,
                                count: collection.catCount,
                                previewURLs: []
                            )
                        }
                    }
                }
                
                var result: [CollectionPreview] = []
                for try await preview in group {
                    result.append(preview)
                }
                return result.sorted { (order[$0.id] ?? Int.max) < (order[$1.id] ?? Int.max) }
            }
            
            collections = previews
        } catch is CancellationError {
            // Ignore refresh cancellations to avoid showing transient errors
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func createCollection(name: String, for username: String) async throws {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { throw CollectionCreationError.emptyName }
        guard !isCreating else { return }
        
        isCreating = true
        defer { isCreating = false }
        
        let createResponse = try await api.createCollection(name: trimmed, description: nil)
        let detail = try? await api.getCollection(
            id: createResponse.collection.id,
            limit: 4,
            cursor: nil,
            includeAuthContext: true
        )
        
        let preview = CollectionPreview(
            id: createResponse.collection.id,
            name: createResponse.collection.name,
            count: detail?.collection.catCount ?? createResponse.collection.catCount,
            previewURLs: detail?.cats.compactMap { $0.imageUrl } ?? []
        )
        
        if let index = collections.firstIndex(where: { $0.id == preview.id }) {
            collections[index] = preview
        } else {
            collections.insert(preview, at: 0)
        }
        
        errorMessage = nil
        lastUsername = username
    }
    
    func addCat(_ catId: UUID, to collectionId: UUID) async throws {
        _ = try await api.addCatToCollection(collectionId: collectionId, catId: catId)
        if let idx = collections.firstIndex(where: { $0.id == collectionId }) {
            let updated = CollectionPreview(
                id: collections[idx].id,
                name: collections[idx].name,
                count: collections[idx].count + 1,
                previewURLs: collections[idx].previewURLs
            )
            collections[idx] = updated
        }
    }
}
