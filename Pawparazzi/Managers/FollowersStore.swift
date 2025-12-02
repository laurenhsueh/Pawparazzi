//
//  FollowersStore.swift
//  Pawparazzi
//
//  Created by ChatGPT on 12/2/25.
//

import Foundation

@MainActor
final class FollowersStore: ObservableObject {
    enum Relationship: String {
        case followers
        case following
    }

    @Published private(set) var followers: [FollowerSummary] = []
    @Published private(set) var following: [FollowerSummary] = []
    @Published var isLoadingFollowers: Bool = false
    @Published var isLoadingFollowing: Bool = false
    @Published var errorMessage: String?
    @Published var isMutatingFollow: Bool = false

    private let api: PawparazziAPI
    private var cachedUsername: String?
    private var followersCursor: String?
    private var followingCursor: String?
    private var hasMoreFollowers: Bool = true
    private var hasMoreFollowing: Bool = true

    init(api: PawparazziAPI = .shared) {
        self.api = api
    }

    func refresh(username: String? = nil) async {
        followersCursor = nil
        followingCursor = nil
        hasMoreFollowers = true
        hasMoreFollowing = true
        await loadList(.followers, reset: true, username: username)
        await loadList(.following, reset: true, username: username)
    }

    func loadMoreFollowersIfNeeded(current user: FollowerSummary?) async {
        guard let user else { return }
        let thresholdIndex = followers.index(followers.endIndex, offsetBy: -5, limitedBy: followers.startIndex) ?? followers.startIndex
        if followers.firstIndex(where: { $0.username == user.username }) == thresholdIndex {
            await loadList(.followers, reset: false, username: cachedUsername)
        }
    }

    func loadMoreFollowingIfNeeded(current user: FollowerSummary?) async {
        guard let user else { return }
        let thresholdIndex = following.index(following.endIndex, offsetBy: -5, limitedBy: following.startIndex) ?? following.startIndex
        if following.firstIndex(where: { $0.username == user.username }) == thresholdIndex {
            await loadList(.following, reset: false, username: cachedUsername)
        }
    }

    func toggleFollow(username: String, action: String? = nil) async {
        guard !isMutatingFollow else { return }
        isMutatingFollow = true
        defer { isMutatingFollow = false }

        do {
            _ = try await api.followUser(username: username, action: action)
            await refresh(username: cachedUsername)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func loadList(
        _ relationship: Relationship,
        reset: Bool,
        username: String?
    ) async {
        guard shouldLoadMore(for: relationship) || reset else { return }

        setLoading(true, for: relationship)
        defer { setLoading(false, for: relationship) }

        do {
            let resolvedUsername = try await resolveUsername(preferred: username)
            cachedUsername = resolvedUsername
            let cursor = reset ? nil : cursor(for: relationship)

            let response = try await api.listFollowers(
                username: resolvedUsername,
                limit: 20,
                cursor: cursor,
                relationship: relationship.rawValue
            )

            if reset {
                assign(response.followers, to: relationship)
            } else {
                append(response.followers, to: relationship)
            }

            updateCursor(response.nextCursor, for: relationship)
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func resolveUsername(preferred: String?) async throws -> String {
        if let preferred, !preferred.isEmpty {
            return preferred
        }
        if let cachedUsername {
            return cachedUsername
        }
        if let profile = UserStore.shared.profile {
            cachedUsername = profile.username
            return profile.username
        }
        let response = try await api.fetchProfile()
        cachedUsername = response.user.username
        return response.user.username
    }

    private func shouldLoadMore(for relationship: Relationship) -> Bool {
        switch relationship {
        case .followers:
            return hasMoreFollowers && !isLoadingFollowers
        case .following:
            return hasMoreFollowing && !isLoadingFollowing
        }
    }

    private func cursor(for relationship: Relationship) -> String? {
        switch relationship {
        case .followers:
            return followersCursor
        case .following:
            return followingCursor
        }
    }

    private func updateCursor(_ cursor: String?, for relationship: Relationship) {
        switch relationship {
        case .followers:
            followersCursor = cursor
            hasMoreFollowers = cursor != nil
        case .following:
            followingCursor = cursor
            hasMoreFollowing = cursor != nil
        }
    }

    private func assign(_ list: [FollowerSummary], to relationship: Relationship) {
        switch relationship {
        case .followers:
            followers = list
        case .following:
            following = list
        }
    }

    private func append(_ list: [FollowerSummary], to relationship: Relationship) {
        switch relationship {
        case .followers:
            followers.append(contentsOf: list)
        case .following:
            following.append(contentsOf: list)
        }
    }

    private func setLoading(_ isLoading: Bool, for relationship: Relationship) {
        switch relationship {
        case .followers:
            isLoadingFollowers = isLoading
        case .following:
            isLoadingFollowing = isLoading
        }
    }
}


