//
//  PawparazziAPI.swift
//  Pawparazzi
//
//  Created by ChatGPT on 12/2/25.
//

import Foundation

@MainActor
final class PawparazziAPI {
    static let shared = PawparazziAPI()

    private let client: APIClient
    private let storage: UserDefaults
    private let sessionStorageKey = "PawparazziSessionToken"

    private(set) var sessionToken: String? {
        didSet {
            if let token = sessionToken {
                storage.set(token, forKey: sessionStorageKey)
            } else {
                storage.removeObject(forKey: sessionStorageKey)
            }
        }
    }

    init(
        client: APIClient = APIClient(),
        storage: UserDefaults = .standard
    ) {
        self.client = client
        self.storage = storage
        self.sessionToken = storage.string(forKey: sessionStorageKey)
    }

    func clearSession() {
        sessionToken = nil
    }

    // MARK: - Health

    func healthCheck() async throws -> String {
        try await client.getPlainText(path: "/")
    }

    // MARK: - User Endpoints

    func checkUsernameAvailability(_ username: String) async throws -> Bool {
        let query = [URLQueryItem(name: "username", value: username)]
        let response: UsernameAvailabilityResponse = try await client.send(
            path: "/users/checkUsername",
            method: .get,
            queryItems: query
        )
        return response.available
    }

    func fetchProfile(username: String? = nil) async throws -> UserProfileResponse {
        var items: [URLQueryItem] = []
        let token = try requireSessionToken()
        items.append(.init(name: "session_token", value: token))
        if let username {
            items.append(.init(name: "username", value: username))
        }

        return try await client.send(
            path: "/users/profile",
            method: .get,
            queryItems: items
        )
    }

    @discardableResult
    func register(username: String, email: String, passwordHash: String) async throws -> SessionTokenResponse {
        let body = RegisterRequest(username: username, passwdHash: passwordHash, email: email)
        let response: SessionTokenResponse = try await client.send(
            path: "/users/register",
            method: .post,
            body: body
        )

        sessionToken = response.sessionToken
        return response
    }

    @discardableResult
    func login(email: String, passwordHash: String) async throws -> LoginResponse {
        let body = LoginRequest(email: email, passwdHash: passwordHash)
        let response: LoginResponse = try await client.send(
            path: "/users/login",
            method: .post,
            body: body
        )

        sessionToken = response.sessionToken
        return response
    }

    @discardableResult
    func updateProfile(bio: String?, location: String?) async throws -> UserProfileResponse {
        let token = try requireSessionToken()
        let body = UpdateProfileRequest(sessionToken: token, bio: bio, location: location)
        return try await client.send(
            path: "/users/update",
            method: .post,
            body: body
        )
    }

    func changePassword(currentHash: String, newHash: String) async throws {
        let token = try requireSessionToken()
        let body = ChangePasswordRequest(
            sessionToken: token,
            currentPasswdHash: currentHash,
            newPasswdHash: newHash
        )
        _ = try await client.send(
            path: "/users/changePassword",
            method: .post,
            body: body
        ) as BasicResponse
    }

    @discardableResult
    func changeAvatar(base64Image: String) async throws -> UserProfileResponse {
        let token = try requireSessionToken()
        let body = ChangeAvatarRequest(sessionToken: token, avatarBase64: base64Image)
        return try await client.send(
            path: "/users/changeAvatar",
            method: .post,
            body: body
        )
    }

    // MARK: - Follow

    @discardableResult
    func followUser(username: String, action: String? = nil) async throws -> FollowActionResponse {
        let token = try requireSessionToken()
        let body = FollowRequest(sessionToken: token, targetUsername: username, action: action)
        return try await client.send(
            path: "/users/follow",
            method: .post,
            body: body
        )
    }

    func listFollowers(
        username: String? = nil,
        limit: Int? = nil,
        cursor: String? = nil
    ) async throws -> FollowersListResponse {
        var items: [URLQueryItem] = []
        let token = try requireSessionToken()
        items.append(.init(name: "session_token", value: token))

        if let username {
            items.append(.init(name: "username", value: username))
        }
        if let limit {
            items.append(.init(name: "limit", value: "\(limit)"))
        }
        if let cursor {
            items.append(.init(name: "cursor", value: cursor))
        }

        return try await client.send(
            path: "/users/listFollowers",
            method: .get,
            queryItems: items
        )
    }

    func listFollowing(
        username: String? = nil,
        limit: Int? = nil,
        cursor: String? = nil
    ) async throws -> FollowingListResponse {
        var items: [URLQueryItem] = []
        let token = try requireSessionToken()
        items.append(.init(name: "session_token", value: token))

        if let username {
            items.append(.init(name: "username", value: username))
        }
        if let limit {
            items.append(.init(name: "limit", value: "\(limit)"))
        }
        if let cursor {
            items.append(.init(name: "cursor", value: cursor))
        }

        return try await client.send(
            path: "/users/listFollowing",
            method: .get,
            queryItems: items
        )
    }

    // MARK: - Cats

    func listCats(
        limit: Int? = nil,
        cursor: String? = nil,
        username: String? = nil,
        includeAuthContext: Bool = true
    ) async throws -> CatListResponse {
        var items: [URLQueryItem] = []
        if includeAuthContext, let token = sessionToken {
            items.append(.init(name: "session_token", value: token))
        }
        if let limit = limit {
            items.append(.init(name: "limit", value: "\(limit)"))
        }
        if let cursor = cursor {
            items.append(.init(name: "cursor", value: cursor))
        }
        if let username = username {
            items.append(.init(name: "username", value: username))
        }

        return try await client.send(
            path: "/cats/list",
            method: .get,
            queryItems: items
        )
    }

    func getCat(id: UUID, includeAuthContext: Bool = true) async throws -> CatDetailResponse {
        var items = [URLQueryItem(name: "id", value: id.uuidString)]
        if includeAuthContext, let token = sessionToken {
            items.append(.init(name: "session_token", value: token))
        }
        return try await client.send(
            path: "/cats/get",
            method: .get,
            queryItems: items
        )
    }

    func searchCats(
        tags: [String],
        mode: String = "any",
        limit: Int? = nil,
        cursor: String? = nil,
        includeAuthContext: Bool = true
    ) async throws -> CatListResponse {
        var items: [URLQueryItem] = [
            .init(name: "tags", value: tags.joined(separator: ",")),
            .init(name: "mode", value: mode)
        ]
        if includeAuthContext, let token = sessionToken {
            items.append(.init(name: "session_token", value: token))
        }

        if let limit = limit {
            items.append(.init(name: "limit", value: "\(limit)"))
        }

        if let cursor = cursor {
            items.append(.init(name: "cursor", value: cursor))
        }

        return try await client.send(
            path: "/cats/search/tags",
            method: .get,
            queryItems: items
        )
    }

    func postCat(
        name: String,
        description: String?,
        tags: [String],
        location: CatLocation?,
        imageBase64: String
    ) async throws -> CatPostResponse {
        let token = try requireSessionToken()
        let tagString = tags.isEmpty ? nil : tags.joined(separator: ",")
        let body = CatPostRequest(
            sessionToken: token,
            name: name,
            description: description,
            tags: tagString,
            locationLatitude: location?.latitude.map { String($0) },
            locationLongitude: location?.longitude.map { String($0) },
            imageBase64: imageBase64
        )

        return try await client.send(
            path: "/cats/post",
            method: .post,
            body: body
        )
    }

    func likeCat(id: UUID) async throws -> CatLikeResponse {
        let token = try requireSessionToken()
        let body = CatLikeRequest(sessionToken: token, catId: id)
        return try await client.send(
            path: "/cats/like",
            method: .post,
            body: body
        )
    }

    func removeLike(id: UUID) async throws -> CatLikeResponse {
        let token = try requireSessionToken()
        let body = CatLikeRequest(sessionToken: token, catId: id)
        return try await client.send(
            path: "/cats/removeLike",
            method: .post,
            body: body
        )
    }

    // MARK: - Collections

    func createCollection(name: String, description: String?) async throws -> CollectionCreateResponse {
        let token = try requireSessionToken()
        let body = CollectionCreateRequest(sessionToken: token, name: name, description: description)
        return try await client.send(
            path: "/collections/create",
            method: .post,
            body: body
        )
    }

    func listCollections(username: String, limit: Int? = nil, cursor: String? = nil) async throws -> CollectionListResponse {
        var items: [URLQueryItem] = [
            .init(name: "username", value: username)
        ]
        if let limit {
            items.append(.init(name: "limit", value: "\(limit)"))
        }
        if let cursor {
            items.append(.init(name: "cursor", value: cursor))
        }

        return try await client.send(
            path: "/collections/list",
            method: .get,
            queryItems: items
        )
    }

    func getCollection(
        id: UUID,
        limit: Int? = nil,
        cursor: String? = nil,
        includeAuthContext: Bool = true
    ) async throws -> CollectionDetailResponse {
        var items: [URLQueryItem] = [
            .init(name: "collection_id", value: id.uuidString)
        ]
        if let limit {
            items.append(.init(name: "limit", value: "\(limit)"))
        }
        if let cursor {
            items.append(.init(name: "cursor", value: cursor))
        }
        if includeAuthContext, let token = sessionToken {
            items.append(.init(name: "session_token", value: token))
        }

        return try await client.send(
            path: "/collections/get",
            method: .get,
            queryItems: items
        )
    }

    func updateCollection(
        id: UUID,
        name: String?,
        description: String?
    ) async throws -> CollectionUpdateResponse {
        let token = try requireSessionToken()
        let body = CollectionUpdateRequest(
            sessionToken: token,
            collectionId: id,
            name: name,
            description: description
        )
        return try await client.send(
            path: "/collections/update",
            method: .post,
            body: body
        )
    }

    func deleteCollection(id: UUID) async throws {
        let token = try requireSessionToken()
        let body = CollectionDeleteRequest(sessionToken: token, collectionId: id)
        _ = try await client.send(
            path: "/collections/delete",
            method: .post,
            body: body
        ) as BasicResponse
    }

    func addCatToCollection(collectionId: UUID, catId: UUID) async throws -> CollectionMutationResponse {
        let token = try requireSessionToken()
        let body = CollectionCatMutationRequest(
            sessionToken: token,
            collectionId: collectionId,
            catId: catId
        )
        return try await client.send(
            path: "/collections/addCat",
            method: .post,
            body: body
        )
    }

    func removeCatFromCollection(collectionId: UUID, catId: UUID) async throws -> CollectionMutationResponse {
        let token = try requireSessionToken()
        let body = CollectionCatMutationRequest(
            sessionToken: token,
            collectionId: collectionId,
            catId: catId
        )
        return try await client.send(
            path: "/collections/removeCat",
            method: .post,
            body: body
        )
    }

    // MARK: - Helpers

    private func requireSessionToken() throws -> String {
        if let token = sessionToken, !token.isEmpty {
            return token
        }
        throw APIError.server(message: "Missing session token.")
    }
}

