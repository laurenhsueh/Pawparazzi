//
//  SessionManager.swift
//  Pawparazzi
//
//  Created by ChatGPT on 12/2/25.
//

import Foundation
import SwiftUI

@MainActor
final class SessionManager: ObservableObject {
    static let shared = SessionManager()

    @Published private(set) var sessionToken: String?

    private let api: PawparazziAPI

    init(api: PawparazziAPI = .shared) {
        self.api = api
        self.sessionToken = api.sessionToken
    }

    var isAuthenticated: Bool {
        guard let sessionToken, !sessionToken.isEmpty else {
            return false
        }
        return true
    }

    func refreshSession() {
        sessionToken = api.sessionToken
    }

    func logout() {
        api.clearSession()
        sessionToken = nil
        UserStore.shared.clear()
    }
}


