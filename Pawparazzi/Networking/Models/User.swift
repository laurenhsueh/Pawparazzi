//
//  User.swift
//  Pawparazzi
//
//  Created by ChatGPT on 12/2/25.
//

import Foundation

/// Represents either a full user or guest profile returned by the API.
/// For guest users, `email` will be `nil` and `collections` fields may be present.
struct UserProfile: Codable, Identifiable, Hashable {
    var id: String { username }

    let username: String
    let bio: String?
    let location: String?
    let email: String?
    let avatarUrl: String?
    let postCount: Int
    let followerCount: Int
    let followingCount: Int
    let isFollowed: Bool?

    // Guest profiles may include a preview of collections
    let collections: [CollectionModel]?
    let collectionsNextCursor: String?

    enum CodingKeys: String, CodingKey {
        case username
        case bio
        case location
        case email
        case avatarUrl
        case postCount
        case followerCount
        case followingCount
        case isFollowed
        case collections
        case collectionsNextCursor
    }

    init(
        username: String,
        bio: String?,
        location: String?,
        email: String?,
        avatarUrl: String?,
        postCount: Int,
        followerCount: Int,
        followingCount: Int,
        isFollowed: Bool?,
        collections: [CollectionModel]?,
        collectionsNextCursor: String?
    ) {
        self.username = username
        self.bio = bio
        self.location = location
        self.email = email
        self.avatarUrl = AssetURLResolver.resolve(avatarUrl)
        self.postCount = postCount
        self.followerCount = followerCount
        self.followingCount = followingCount
        self.isFollowed = isFollowed
        self.collections = collections
        self.collectionsNextCursor = collectionsNextCursor
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let username = try container.decode(String.self, forKey: .username)
        let bio = try container.decodeIfPresent(String.self, forKey: .bio)
        let location = try container.decodeIfPresent(String.self, forKey: .location)
        let email = try container.decodeIfPresent(String.self, forKey: .email)
        let avatarUrl = try container.decodeIfPresent(String.self, forKey: .avatarUrl)
        let postCount = try container.decodeIfPresent(Int.self, forKey: .postCount) ?? 0
        let followerCount = try container.decodeIfPresent(Int.self, forKey: .followerCount) ?? 0
        let followingCount = try container.decodeIfPresent(Int.self, forKey: .followingCount) ?? 0
        let isFollowed = try container.decodeIfPresent(Bool.self, forKey: .isFollowed)
        let collections = try container.decodeIfPresent([CollectionModel].self, forKey: .collections)
        let collectionsNextCursor = try container.decodeIfPresent(String.self, forKey: .collectionsNextCursor)

        self.init(
            username: username,
            bio: bio,
            location: location,
            email: email,
            avatarUrl: avatarUrl,
            postCount: postCount,
            followerCount: followerCount,
            followingCount: followingCount,
            isFollowed: isFollowed,
            collections: collections,
            collectionsNextCursor: collectionsNextCursor
        )
    }
}

