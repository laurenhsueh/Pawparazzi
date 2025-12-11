//
//  FollowerSummary.swift
//  Pawparazzi
//
//  Created by ChatGPT on 12/2/25.
//

import Foundation

/// Represents a follower/following edge.
struct FollowerEdge: Codable, Identifiable, Hashable {
    var id: String { user.username }

    let user: UserProfile
    let followedAt: Date?
}

