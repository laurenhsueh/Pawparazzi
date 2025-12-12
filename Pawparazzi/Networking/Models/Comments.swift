//
//  Comments.swift
//  Pawparazzi
//
//  Created by Lauren Hsueh on 12/11/25.
//
import Foundation

struct CommentModel: Codable, Identifiable, Hashable {
    let id: UUID
    let user: UserProfile
    let comment: String
    let createdAt: Date
}
