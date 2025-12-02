//
//  APIResponseEnvelope.swift
//  Pawparazzi
//
//  Created by ChatGPT on 12/2/25.
//

import Foundation

protocol APIResponseEnvelope {
    var success: Bool { get }
    var error: String { get }
}

