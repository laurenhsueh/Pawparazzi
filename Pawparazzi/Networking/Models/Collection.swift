import Foundation

struct CollectionModel: Codable, Identifiable, Hashable {
    let id: UUID
    let owner: UserProfile
    let name: String
    let description: String?
    let catCount: Int
    let createdAt: Date?
}

