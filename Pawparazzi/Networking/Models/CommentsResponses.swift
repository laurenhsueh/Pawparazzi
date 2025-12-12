//
//  CommentsResponses.swift
//  Pawparazzi
//
//  Created by Lauren Hsueh on 12/11/25.
//
import Foundation

struct CommentListResponse: Decodable, APIResponseEnvelope {
    let success: Bool
    let error: String
    let comments: [CommentModel]
    let nextPage: Int?
}

struct PostCommentResponse: Decodable, APIResponseEnvelope {
    let success: Bool
    let error: String
    let comment: CommentModel
}

struct DeleteCommentResponse: Decodable, APIResponseEnvelope {
    let success: Bool
    let error: String
    let status: String
}
