//
//  BaseResponses.swift
//  Pawparazzi
//
//  Created by ChatGPT on 12/2/25.
//

import Foundation

struct BasicResponse: Codable, APIResponseEnvelope {
    let success: Bool
    let error: String
}

struct UsernameAvailabilityResponse: Codable, APIResponseEnvelope {
    let success: Bool
    let error: String
    let available: Bool
}

struct SessionTokenResponse: Codable, APIResponseEnvelope {
    let success: Bool
    let error: String
    let sessionToken: String
}

struct LoginResponse: Codable, APIResponseEnvelope {
    let success: Bool
    let error: String
    let sessionToken: String
    let user: UserProfile
}

struct UserProfileResponse: Codable, APIResponseEnvelope {
    let success: Bool
    let error: String
    let user: UserProfile
}

