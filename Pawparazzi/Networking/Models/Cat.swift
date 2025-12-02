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
    let tags: [String]?
    let createdAt: Date?
    let username: String
    let description: String?
    let location: CatLocation?
    let imageUrl: String?
    let posterAvatarUrl: String?
    var likes: Int
    var isLiked: Bool?

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case tags
        case createdAt
        case username
        case description
        case location
        case imageUrl
        case posterAvatarUrl
        case likes
        case isLiked = "liked"
    }

    init(
        id: UUID,
        name: String,
        tags: [String]?,
        createdAt: Date?,
        username: String,
        description: String?,
        location: CatLocation?,
        imageUrl: String?,
        posterAvatarUrl: String?,
        likes: Int,
        isLiked: Bool?
    ) {
        self.id = id
        self.name = name
        self.tags = tags
        self.createdAt = createdAt
        self.username = username
        self.description = description
        self.location = location
        self.imageUrl = AssetURLResolver.resolve(imageUrl)
        self.posterAvatarUrl = AssetURLResolver.resolve(posterAvatarUrl)
        self.likes = likes
        self.isLiked = isLiked
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let id = try container.decode(UUID.self, forKey: .id)
        let name = try container.decode(String.self, forKey: .name)
        let tags = try container.decodeIfPresent([String].self, forKey: .tags)
        let createdAt = try container.decodeIfPresent(Date.self, forKey: .createdAt)
        let username = try container.decode(String.self, forKey: .username)
        let description = try container.decodeIfPresent(String.self, forKey: .description)
        let location = try container.decodeIfPresent(CatLocation.self, forKey: .location)
        let imageUrl = try container.decodeIfPresent(String.self, forKey: .imageUrl)
        let posterAvatarUrl = try container.decodeIfPresent(String.self, forKey: .posterAvatarUrl)
        let likes = try container.decode(Int.self, forKey: .likes)
        let isLiked = try container.decodeIfPresent(Bool.self, forKey: .isLiked)

        self.init(
            id: id,
            name: name,
            tags: tags,
            createdAt: createdAt,
            username: username,
            description: description,
            location: location,
            imageUrl: imageUrl,
            posterAvatarUrl: posterAvatarUrl,
            likes: likes,
            isLiked: isLiked
        )
    }
}

