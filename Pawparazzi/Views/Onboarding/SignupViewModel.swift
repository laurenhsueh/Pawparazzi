//
//  SignupViewModel.swift
//  Pawparazzi
//
//  Created by ChatGPT on 12/2/25.
//

import Foundation
import SwiftUI
import UIKit

@MainActor
final class SignupViewModel: ObservableObject {
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

    func validateCredentials(using model: OnboardingModel) -> Bool {
        if model.username.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            errorMessage = SignupError.missingUsername.localizedDescription
            return false
        }

        if model.email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            errorMessage = "Email is required."
            return false
        }

        if model.password.count < 8 {
            errorMessage = "Password must be at least 8 characters."
            return false
        }

        if model.password != model.confirmPassword {
            errorMessage = "Passwords do not match."
            return false
        }

        errorMessage = nil
        return true
    }

    func completeOnboarding(using model: OnboardingModel) async {
        guard !isLoading else { return }
        errorMessage = nil
        isLoading = true
        defer { isLoading = false }

        do {
            let username = try validatedUsername(from: model)
            let email = model.email.trimmingCharacters(in: .whitespacesAndNewlines)

            let usernameAvailable = try await api.checkUsernameAvailability(username)
            guard usernameAvailable else {
                throw SignupError.usernameTaken
            }

            let hash = model.password.sha256()
            try await api.register(
                username: username,
                email: email,
                passwordHash: hash
            )

            try await updateProfileIfNeeded(using: model)
            try await uploadAvatarIfNeeded(using: model)

            sessionManager.refreshSession()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func validatedUsername(from model: OnboardingModel) throws -> String {
        let trimmed = model.username.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            throw SignupError.missingUsername
        }
        return trimmed
    }

    private func updateProfileIfNeeded(using model: OnboardingModel) async throws {
        let bio = model.bio.trimmingCharacters(in: .whitespacesAndNewlines)
        let location = model.location.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !bio.isEmpty || !location.isEmpty else { return }

        _ = try await api.updateProfile(
            bio: bio.isEmpty ? nil : bio,
            location: location.isEmpty ? nil : location
        )
    }

    private func uploadAvatarIfNeeded(using model: OnboardingModel) async throws {
        guard let image = model.profileImage,
              let data = image.jpegData(compressionQuality: 0.85) else {
            return
        }

        let base64 = data.base64EncodedString()
        _ = try await api.changeAvatar(base64Image: base64)
    }
}

enum SignupError: LocalizedError {
    case missingUsername
    case usernameTaken

    var errorDescription: String? {
        switch self {
        case .missingUsername:
            return "Pick a username to continue."
        case .usernameTaken:
            return "That username or email is already taken."
        }
    }
}


