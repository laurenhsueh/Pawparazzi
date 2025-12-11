//
//  UserStore.swift
//  Pawparazzi
//
//  Created by ChatGPT on 12/2/25.
//

import Foundation
import SwiftUI
import UIKit

@MainActor
final class UserStore: ObservableObject {
    static let shared = UserStore()

    @Published private(set) var profile: UserProfile?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var isUpdatingProfile: Bool = false
    @Published var isUpdatingAvatar: Bool = false

    private let api: PawparazziAPI
    private var loadProfileTask: Task<Void, Never>?

    init(api: PawparazziAPI = .shared) {
        self.api = api
    }

    func loadProfile(username: String? = nil) async {
        if let loadProfileTask {
            await loadProfileTask.value
            if username == nil || username == profile?.username {
                return
            }
        }

        let task = Task { [weak self] in
            guard let self else { return }
            await self.performLoadProfile(username: username)
        }

        loadProfileTask = task
        await task.value
        loadProfileTask = nil
    }

    private func performLoadProfile(username: String?) async {
        guard !isLoading else { return }
        isLoading = true
        defer { isLoading = false }

        do {
            let response = try await api.fetchProfile(username: username)
            profile = response.user
            errorMessage = nil
        } catch is CancellationError {
            // Silently ignore refresh cancellations
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func updateProfile(bio: String?, location: String?) async {
        guard !isUpdatingProfile else { return }
        isUpdatingProfile = true
        defer { isUpdatingProfile = false }

        do {
            let response = try await api.updateProfile(bio: bio, location: location)
            profile = response.user
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func updateAvatar(image: UIImage) async {
        guard !isUpdatingAvatar else { return }
        isUpdatingAvatar = true
        defer { isUpdatingAvatar = false }

        do {
            guard let data = image.jpegData(compressionQuality: 0.85) else {
                throw APIError.encodingFailed
            }

            let base64 = data.base64EncodedString()
            let response = try await api.changeAvatar(base64Image: base64)
            profile = response.user
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func clear() {
        profile = nil
        errorMessage = nil
    }
}


