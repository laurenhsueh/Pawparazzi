//
//  FollowerSummary.swift
//  Pawparazzi
//
//  Created by ChatGPT on 12/2/25.
//

import Foundation

struct FollowerSummary: Codable, Identifiable, Hashable {
    var id: String { username }
    let username: String
    let bio: String?
    let location: String?
    let avatarUrl: String?
    let followedAt: Date?

    enum CodingKeys: String, CodingKey {
        case username
        case bio
        case location
        case avatarUrl
        case followedAt
    }

    init(
        username: String,
        bio: String?,
        location: String?,
        avatarUrl: String?,
        followedAt: Date?
    ) {
        self.username = username
        self.bio = bio
        self.location = location
        self.avatarUrl = AssetURLResolver.resolve(avatarUrl)
        self.followedAt = followedAt
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let username = try container.decode(String.self, forKey: .username)
        let bio = try container.decodeIfPresent(String.self, forKey: .bio)
        let location = try container.decodeIfPresent(String.self, forKey: .location)
        let avatarUrl = try container.decodeIfPresent(String.self, forKey: .avatarUrl)
        let followedAt = try container.decodeIfPresent(Date.self, forKey: .followedAt)

        self.init(
            username: username,
            bio: bio,
            location: location,
            avatarUrl: avatarUrl,
            followedAt: followedAt
        )
    }
}

