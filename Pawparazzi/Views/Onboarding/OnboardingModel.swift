//
//  OnboardingModel.swift
//  Pawparazzi
//
//  Created by Lauren Hsueh on 12/2/25.
//

import Foundation
import SwiftUI

class OnboardingModel: ObservableObject {
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var confirmPassword: String = ""
    @Published var username: String = ""
    @Published var name: String = ""
    @Published var bio: String = ""
    @Published var profileImage: UIImage?
    @Published var collections: [String] = []
    @Published var friends: [String] = []
}
