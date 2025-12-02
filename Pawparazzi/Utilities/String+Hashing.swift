//
//  String+Hashing.swift
//  Pawparazzi
//
//  Created by ChatGPT on 12/2/25.
//

import Foundation
import CryptoKit

extension String {
    func sha256() -> String {
        let data = Data(utf8)
        let digest = SHA256.hash(data: data)
        return digest.map { String(format: "%02x", $0) }.joined()
    }
}


