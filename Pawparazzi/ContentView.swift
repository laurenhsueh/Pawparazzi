//
//  ContentView.swift
//  Pawparazzi
//
//  Created by Lauren Hsueh on 11/13/25.
//
import SwiftUI

// MARK: - SwiftUI View
struct ContentView: View {
    @StateObject private var manager = SupabaseManager.shared
    @State private var name = ""
    @State private var color = ""
    @State private var niceScore = 5
    @State private var injured = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                TextField("Cat Name", text: $name)
                    .textFieldStyle(.roundedBorder)
                TextField("Color", text: $color)
                    .textFieldStyle(.roundedBorder)
                Stepper("Niceness: \(niceScore)", value: $niceScore, in: 1...10)
                Toggle("Injured?", isOn: $injured)
                
                Button("Upload Cat") {
                    Task {
                        await manager.uploadCat(name: name, color: color, niceScore: niceScore, injured: injured)
                    }
                }
                .buttonStyle(.borderedProminent)
                
                Divider()
                
                List(manager.cats) { cat in
                    VStack(alignment: .leading) {
                        Text(cat.name).font(.headline)
                        Text("Color: \(cat.color)")
                        Text("Nice: \(cat.nice_score) / 10")
                        Text(cat.injured ? "🚨 Injured" : "✅ Healthy")
                    }
                }
            }
            .padding()
            .navigationTitle("Cat Tracker 🐱")
            .task {
                await manager.fetchCats()
            }
        }
    }
}
