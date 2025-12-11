//
//  LoginViewModel.swift
//  Pawparazzi
//
//  Created by ChatGPT on 12/2/25.
//

import Foundation
import SwiftUI

@MainActor
final class LoginViewModel: ObservableObject {
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    private let api: PawparazziAPI
    private let sessionManager: SessionManager

    init(
        api: PawparazziAPI = .shared,
        sessionManager: SessionManager = .shared
    ) {
        self.api = api
        self.sessionManager = sessionManager
    }

    func login() async {
        guard !isLoading else { return }
        errorMessage = nil

        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedEmail.isEmpty else {
            errorMessage = "Enter your email."
            return
        }

        guard trimmedEmail.contains("@") else {
            errorMessage = "Enter a valid email."
            return
        }

        guard password.count >= 8 else {
            errorMessage = "Password must be at least 8 characters."
            return
        }

        isLoading = true
        defer { isLoading = false }

        do {
            let hash = password.sha256()
            _ = try await api.login(email: trimmedEmail, passwordHash: hash)
            sessionManager.refreshSession()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
