//
//  Cat.swift
//  Pawparazzi
//
//  Created by ChatGPT on 12/2/25.
//

import Foundation

struct CatLocation: Codable, Hashable {
    let latitude: Double?
    let longitude: Double?
}

struct CatModel: Codable, Identifiable, Hashable {
    let id: UUID
    let name: String
    let tags: [String]?
    let createdAt: Date?
    let username: String
    let description: String?
    let location: CatLocation?
    let imageUrl: String?
    var likes: Int
}

