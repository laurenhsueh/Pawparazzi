//
//  PawparazziApp.swift
//  Pawparazzi
//
//  Created by Lauren Hsueh on 11/13/25.
//

import SwiftUI

@main
struct PawparazziApp: App {
    @StateObject private var sessionManager = SessionManager.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(sessionManager)
        }
    }
}
