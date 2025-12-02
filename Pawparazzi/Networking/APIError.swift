//
//  APIError.swift
//  Pawparazzi
//
//  Created by ChatGPT on 12/2/25.
//

import Foundation

enum APIError: LocalizedError {
    case invalidURL
    case encodingFailed
    case decodingFailed(underlying: Error)
    case network(underlying: Error)
    case http(status: Int, message: String)
    case server(message: String)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid request URL."
        case .encodingFailed:
            return "Failed to encode request body."
        case .decodingFailed(let underlying):
            return "Failed to decode response: \(underlying.localizedDescription)"
        case .network(let underlying):
            return "Network error: \(underlying.localizedDescription)"
        case .http(let status, let message):
            return "HTTP \(status): \(message)"
        case .server(let message):
            return message.isEmpty ? "Server error." : message
        }
    }
}

