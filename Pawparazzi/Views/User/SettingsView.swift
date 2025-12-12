//
//  SettingsView.swift
//  Pawparazzi
//
//  Created by Lauren Hsueh on 12/11/25.
//

import SwiftUI
struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var userStore = UserStore.shared

    var body: some View {
        NavigationView {
            List {
                Section {
                    Button(role: .destructive) {
                        Task {
                            SessionManager.shared.logout()
                            dismiss()
                        }
                    } label: {
                        Text("Log Out")
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}
