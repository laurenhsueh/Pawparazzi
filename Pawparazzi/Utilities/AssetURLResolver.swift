//
//  AssetURLResolver.swift
//  Pawparazzi
//
//  Created by ChatGPT on 12/2/25.
//

import Foundation

enum AssetURLResolver {
    private static let baseURL = URL(string: "https://pawparazzi-s3.justzhu.com/")!

    static func resolve(_ path: String?) -> String? {
        guard var path, !path.isEmpty else {
            return nil
        }

        if path.hasPrefix("http://") || path.hasPrefix("https://") {
            return path
        }

        if path.hasPrefix("/") {
            path.removeFirst()
        }

        return baseURL.appendingPathComponent(path).absoluteString
    }
}


