//
//  OnboardingModel.swift
//  Pawparazzi
//
//  Created by Lauren Hsueh on 12/2/25.
//

import Foundation
import SwiftUI

/// Persists onboarding progress so users can resume after quitting.
struct OnboardingStorage {
    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    // MARK: - Keys
    private enum Keys {
        static let currentStep = "onboarding.currentStep"
        static let email = "onboarding.email"
        static let password = "onboarding.password"
        static let confirmPassword = "onboarding.confirmPassword"
        static let username = "onboarding.username"
        static let name = "onboarding.name"
        static let location = "onboarding.location"
        static let bio = "onboarding.bio"
        static let profileImage = "onboarding.profileImage"
    }

    // MARK: - Stored Properties

    var currentStep: Int {
        get { defaults.integer(forKey: Keys.currentStep) }
        set { defaults.set(newValue, forKey: Keys.currentStep) }
    }

    var email: String {
        get { defaults.string(forKey: Keys.email) ?? "" }
        set { defaults.set(newValue, forKey: Keys.email) }
    }

    var password: String {
        get { defaults.string(forKey: Keys.password) ?? "" }
        set { defaults.set(newValue, forKey: Keys.password) }
    }

    var confirmPassword: String {
        get { defaults.string(forKey: Keys.confirmPassword) ?? "" }
        set { defaults.set(newValue, forKey: Keys.confirmPassword) }
    }

    var username: String {
        get { defaults.string(forKey: Keys.username) ?? "" }
        set { defaults.set(newValue, forKey: Keys.username) }
    }

    var name: String {
        get { defaults.string(forKey: Keys.name) ?? "" }
        set { defaults.set(newValue, forKey: Keys.name) }
    }

    var location: String {
        get { defaults.string(forKey: Keys.location) ?? "" }
        set { defaults.set(newValue, forKey: Keys.location) }
    }

    var bio: String {
        get { defaults.string(forKey: Keys.bio) ?? "" }
        set { defaults.set(newValue, forKey: Keys.bio) }
    }

    var profileImageData: Data? {
        get { defaults.data(forKey: Keys.profileImage) }
        set {
            if let data = newValue {
                defaults.set(data, forKey: Keys.profileImage)
            } else {
                defaults.removeObject(forKey: Keys.profileImage)
            }
        }
    }

    // MARK: - Helpers

    func clear() {
        [
            Keys.currentStep,
            Keys.email,
            Keys.password,
            Keys.confirmPassword,
            Keys.username,
            Keys.name,
            Keys.location,
            Keys.bio,
            Keys.profileImage
        ].forEach { defaults.removeObject(forKey: $0) }
    }
}

final class OnboardingModel: ObservableObject {
    private var storage: OnboardingStorage

    @Published var currentStep: Int {
        didSet { storage.currentStep = currentStep }
    }

    @Published var email: String {
        didSet { storage.email = email }
    }
    @Published var password: String {
        didSet { storage.password = password }
    }
    @Published var confirmPassword: String {
        didSet { storage.confirmPassword = confirmPassword }
    }
    @Published var username: String {
        didSet { storage.username = username }
    }
    @Published var name: String {
        didSet { storage.name = name }
    }
    @Published var location: String {
        didSet { storage.location = location }
    }
    @Published var bio: String {
        didSet { storage.bio = bio }
    }
    @Published var profileImage: UIImage? {
        didSet {
            let data = profileImage?.jpegData(compressionQuality: 0.85)
            storage.profileImageData = data
        }
    }
    @Published var collections: [String] = []
    @Published var friends: [String] = []

    init(storage: OnboardingStorage = OnboardingStorage()) {
        self.storage = storage
        self.currentStep = storage.currentStep
        self.email = storage.email
        self.password = storage.password
        self.confirmPassword = storage.confirmPassword
        self.username = storage.username
        self.name = storage.name
        self.location = storage.location
        self.bio = storage.bio
        if let data = storage.profileImageData {
            self.profileImage = UIImage(data: data)
        } else {
            self.profileImage = nil
        }
    }

    func reset() {
        currentStep = 0
        email = ""
        password = ""
        confirmPassword = ""
        username = ""
        name = ""
        location = ""
        bio = ""
        profileImage = nil
        collections = []
        friends = []
        storage.clear()
    }
}
