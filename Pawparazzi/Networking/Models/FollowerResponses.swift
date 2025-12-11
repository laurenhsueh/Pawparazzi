//
//  FollowerResponses.swift
//  Pawparazzi
//
//  Created by ChatGPT on 12/2/25.
//

import Foundation

struct FollowActionResponse: Codable, APIResponseEnvelope {
    let success: Bool
    let error: String
    let status: String
}

struct FollowersListResponse: Codable, APIResponseEnvelope {
    let success: Bool
    let error: String
    let followers: [FollowerEdge]
    let nextCursor: String?
}

struct FollowingListResponse: Codable, APIResponseEnvelope {
    let success: Bool
    let error: String
    let following: [FollowerEdge]
    let nextCursor: String?
}

