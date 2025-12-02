//
//  CatResponses.swift
//  Pawparazzi
//
//  Created by ChatGPT on 12/2/25.
//

import Foundation

struct CatListResponse: Codable, APIResponseEnvelope {
    let success: Bool
    let error: String
    let cats: [CatModel]
    let nextCursor: String?
}

struct CatDetailResponse: Codable, APIResponseEnvelope {
    let success: Bool
    let error: String
    let cat: CatModel
}

struct CatPostResponse: Codable, APIResponseEnvelope {
    let success: Bool
    let error: String
    let cat: CatModel
}

struct CatLikeResponse: Codable, APIResponseEnvelope {
    let success: Bool
    let error: String
    let catId: UUID
    let likes: Int
    let liked: Bool
}

