//
//  SupabaseManager.swift
//  Pawparazzi
//
//  Created by Lauren Hsueh on 11/13/25.
//

import SwiftUI
import Supabase

// MARK: - Data Model
struct Cat: Codable, Identifiable {
    let id: UUID?
    let name: String
    let color: String
    let nice_score: Int
    let injured: Bool
    let image_url: String?
    let created_at: String?
}

// MARK: - Supabase Manager
@MainActor
class SupabaseManager: ObservableObject {
    static let shared = SupabaseManager()
    
    private init() {}
    
    private let supabase = SupabaseClient(
        supabaseURL: URL(string: "https://sjsgeolqkcrrdqlhsgzx.supabase.co")!,
        supabaseKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNqc2dlb2xxa2NycmRxbGhzZ3p4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjMwMDAzNDEsImV4cCI6MjA3ODU3NjM0MX0.jmjEKErgjccNDuoEshgsgKBM9dTqlt9KV0Qc1SQ1xS8"
    )
    
    @Published var cats: [Cat] = []
    
    // Upload a new cat
    func uploadCat(name: String, color: String, niceScore: Int, injured: Bool) async {
        let newCat = Cat(id: nil, name: name, color: color, nice_score: niceScore, injured: injured, image_url: nil, created_at: nil)
        do {
            try await supabase
                .from("cats")
                .insert(newCat)
                .execute()
            print("✅ Cat uploaded successfully")
            await fetchCats()
        } catch {
            print("❌ Upload failed:", error)
        }
    }
    
    // Fetch all cats
    func fetchCats() async {
        do {
            let response: [Cat] = try await supabase
                .from("cats")
                .select()
                .order("created_at", ascending: false)
                .execute()
                .value

            self.cats = response
            print("🐾 Loaded \(response.count) cats")
        } catch {
            print("❌ Fetch failed:", error)
        }
    }

}
