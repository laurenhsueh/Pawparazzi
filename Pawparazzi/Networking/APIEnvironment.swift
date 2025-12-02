//
//  APIEnvironment.swift
//  Pawparazzi
//
//  Created by ChatGPT on 12/2/25.
//

import Foundation

struct APIEnvironment {
    let baseURL: URL

    func url(for path: String) -> URL {
        if path.hasPrefix("http://") || path.hasPrefix("https://"),
           let absoluteURL = URL(string: path) {
            return absoluteURL
        }

        var cleanedPath = path
        if cleanedPath.first == "/" {
            cleanedPath.removeFirst()
        }

        return baseURL.appendingPathComponent(cleanedPath)
    }
}

extension APIEnvironment {
    static let production = APIEnvironment(
        baseURL: URL(string: "https://pawparazzi.api.justzhu.com/")!
    )
}

