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
}

