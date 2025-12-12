//
//  Requests.swift
//  Pawparazzi
//
//  Created by ChatGPT on 12/2/25.
//

import Foundation

struct RegisterRequest: Encodable {
    let username: String
    let passwdHash: String
    let email: String
}

struct LoginRequest: Encodable {
    let email: String
    let passwdHash: String
}

struct UpdateProfileRequest: Encodable {
    let sessionToken: String
    let bio: String?
    let location: String?
}

struct ChangePasswordRequest: Encodable {
    let sessionToken: String
    let currentPasswdHash: String
    let newPasswdHash: String
}

struct ChangeAvatarRequest: Encodable {
    let sessionToken: String
    let avatarBase64: String
}

struct FollowRequest: Encodable {
    let sessionToken: String
    let targetUsername: String
    let action: String?
}

struct CatPostRequest: Encodable {
    let sessionToken: String
    let name: String
    let description: String?
    let tags: String?
    let locationLatitude: String?
    let locationLongitude: String?
    let imageBase64: String
}

struct CatLikeRequest: Encodable {
    let sessionToken: String
    let catId: UUID
}

struct PostCommentRequest: Codable {
    let sessionToken: String
    let catId: UUID
    let comment: String
}

struct DeleteCommentRequest: Encodable {
    let sessionToken: String
    let commentId: UUID
}

struct CollectionCreateRequest: Encodable {
    let sessionToken: String
    let name: String
    let description: String?
}

struct CollectionUpdateRequest: Encodable {
    let sessionToken: String
    let collectionId: UUID
    let name: String?
    let description: String?
}

struct CollectionDeleteRequest: Encodable {
    let sessionToken: String
    let collectionId: UUID
}

struct CollectionCatMutationRequest: Encodable {
    let sessionToken: String
    let collectionId: UUID
    let catId: UUID
}

