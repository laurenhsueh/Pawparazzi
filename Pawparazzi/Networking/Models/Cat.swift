//
//  Cat.swift
//  Pawparazzi
//
//  Created by ChatGPT on 12/2/25.
//

import Foundation

struct CatLocation: Codable, Hashable {
    let latitude: Double?
    let longitude: Double?
}

struct CatModel: Codable, Identifiable, Hashable {
    let id: UUID
    let name: String
    let tags: [String]
    let createdAt: Date?
    let description: String?
    let location: CatLocation?
    let imageUrl: String?
    var likes: Int
    let poster: UserProfile
    var userLiked: Bool
    var comments: [CommentModel] = []

    /// Backwards compatible alias used by existing views.
    var isLiked: Bool? {
        get { userLiked }
        set { userLiked = newValue ?? false }
    }

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case tags
        case createdAt
        case description
        case location
        case imageUrl
        case likes
        case poster
        case userLiked
    }

    init(
        id: UUID,
        name: String,
        tags: [String],
        createdAt: Date?,
        description: String?,
        location: CatLocation?,
        imageUrl: String?,
        likes: Int,
        poster: UserProfile,
        userLiked: Bool
    ) {
        self.id = id
        self.name = name
        self.tags = tags
        self.createdAt = createdAt
        self.description = description
        self.location = location
        self.imageUrl = AssetURLResolver.resolve(imageUrl)
        self.likes = likes
        self.poster = poster
        self.userLiked = userLiked
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let id = try container.decode(UUID.self, forKey: .id)
        let name = try container.decode(String.self, forKey: .name)
        let tags = try container.decodeIfPresent([String].self, forKey: .tags) ?? []
        let createdAt = try container.decodeIfPresent(Date.self, forKey: .createdAt)
        let description = try container.decodeIfPresent(String.self, forKey: .description)
        let location = try container.decodeIfPresent(CatLocation.self, forKey: .location)
        let imageUrl = try container.decodeIfPresent(String.self, forKey: .imageUrl)
        let likes = try container.decodeIfPresent(Int.self, forKey: .likes) ?? 0
        let poster = try container.decode(UserProfile.self, forKey: .poster)
        let userLiked = try container.decodeIfPresent(Bool.self, forKey: .userLiked) ?? false

        self.init(
            id: id,
            name: name,
            tags: tags,
            createdAt: createdAt,
            description: description,
            location: location,
            imageUrl: imageUrl,
            likes: likes,
            poster: poster,
            userLiked: userLiked
        )
    }
}

