//
//  User.swift
//  Pawparazzi
//
//  Created by ChatGPT on 12/2/25.
//

import Foundation

struct UserProfile: Codable, Identifiable, Hashable {
    var id: String { username }
    let username: String
    let bio: String?
    let location: String?
    let email: String
    let avatarUrl: String?

    enum CodingKeys: String, CodingKey {
        case username
        case bio
        case location
        case email
        case avatarUrl
    }

    init(
        username: String,
        bio: String?,
        location: String?,
        email: String,
        avatarUrl: String?
    ) {
        self.username = username
        self.bio = bio
        self.location = location
        self.email = email
        self.avatarUrl = AssetURLResolver.resolve(avatarUrl)
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let username = try container.decode(String.self, forKey: .username)
        let bio = try container.decodeIfPresent(String.self, forKey: .bio)
        let location = try container.decodeIfPresent(String.self, forKey: .location)
        let email = try container.decode(String.self, forKey: .email)
        let avatarUrl = try container.decodeIfPresent(String.self, forKey: .avatarUrl)

        self.init(
            username: username,
            bio: bio,
            location: location,
            email: email,
            avatarUrl: avatarUrl
        )
    }
}

