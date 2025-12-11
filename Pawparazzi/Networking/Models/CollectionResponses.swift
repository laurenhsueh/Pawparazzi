import Foundation

struct CollectionCreateResponse: Codable, APIResponseEnvelope {
    let success: Bool
    let error: String
    let collection: CollectionModel
}

struct CollectionListResponse: Codable, APIResponseEnvelope {
    let success: Bool
    let error: String
    let collections: [CollectionModel]
    let nextCursor: String?
}

struct CollectionDetailResponse: Codable, APIResponseEnvelope {
    let success: Bool
    let error: String
    let collection: CollectionModel
    let cats: [CatModel]
    let nextCursor: String?
}

struct CollectionUpdateResponse: Codable, APIResponseEnvelope {
    let success: Bool
    let error: String
    let collection: CollectionModel
}

struct CollectionMutationResponse: Codable, APIResponseEnvelope {
    let success: Bool
    let error: String
    let collectionId: UUID
    let catCount: Int
}

