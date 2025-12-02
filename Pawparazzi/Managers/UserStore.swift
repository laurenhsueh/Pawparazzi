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

    init(api: PawparazziAPI = .shared) {
        self.api = api
    }

    func loadProfile(username: String? = nil) async {
        guard !isLoading else { return }
        isLoading = true
        defer { isLoading = false }

        do {
            let response = try await api.fetchProfile(username: username)
            profile = response.user
            errorMessage = nil
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


