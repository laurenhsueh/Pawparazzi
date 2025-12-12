//
//  Comments.swift
//  Pawparazzi
//
//  Created by Lauren Hsueh on 12/11/25.
//
import Foundation

struct CommentModel: Codable, Identifiable, Hashable {
    /// Alias to match `Identifiable`
    var id: UUID { commentId }

    let commentId: UUID
    let catId: UUID
    let comment: String
    let commentAt: Date
    let user: UserProfile
    let isOwner: Bool

    /// Backwards compatible alias used by existing views.
    var createdAt: Date { commentAt }
}
