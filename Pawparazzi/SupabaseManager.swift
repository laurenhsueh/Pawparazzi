//  SupabaseManager.swift
//  Pawparazzi
//
//  Created by Lauren Hsueh on 11/13/25.
//

import SwiftUI
import Supabase

// MARK: - Data Models

struct Cat: Codable, Identifiable {
    let id: UUID
    let name: String
    let location: String?
    let description: String?
    let tags: [String: String]?
    var image_url: String?
    let created_at: String?
}

struct NewCat: Encodable {
    let name: String
    let location: String?
    let description: String
    let tags: [String: String]
    let created_at: String   // <-- add this
}

struct NewCatPhoto: Codable {
    let cat_id: UUID
    let image_url: String
}

// MARK: - Supabase Manager

@MainActor
class SupabaseManager: ObservableObject {
    static let shared = SupabaseManager()
    
    private init() {}
    
    private let supabase = SupabaseClient(
        supabaseURL: URL(string: "https://sjsgeolqkcrrdqlhsgzx.supabase.co")!,
        supabaseKey: "sb_publishable_0FGKAlEwZoxt7jEvE5kSZg_xDYbfLNB"
    )
    
    @Published var cats: [Cat] = []
    
    // MARK: - Create Cat + Photos
    
    func createCatWithPhotos(
        name: String,
        description: String,
        location: String?,
        tags: [String: String],
        imageDataArray: [Data]
    ) async {
        do {
            // 1) Insert the cat and get its id back
            let newCat = NewCat(
                name: name,
                location: location,
                description: description,
                tags: tags,
                created_at: ISO8601DateFormatter().string(from: Date())
            )
            
            let insertedCats: [Cat] = try await supabase
                .from("cats")
                .insert(newCat)
                .select()
                .execute()
                .value
            
            guard let insertedCat = insertedCats.first else {
                print("❌ Failed to get inserted cat")
                return
            }
            
            let catID = insertedCat.id
            
            // 2) Upload each photo to Storage & insert cat_photos rows
            if !imageDataArray.isEmpty {
                for data in imageDataArray {
                    let path = "cats/\(catID.uuidString)/\(UUID().uuidString).jpg"
                    
                    // Upload to a bucket (e.g. "cat-images")
                    try await supabase.storage
                        .from("cat-photos")
                        .upload(
                            path,
                            data: data
                        )
                    
                    // Get a public URL for that path
                    let publicURL = try supabase.storage
                        .from("cat-photos")
                        .getPublicURL(path: path)
                    
                    let newPhoto = NewCatPhoto(cat_id: catID, image_url: publicURL.absoluteString)
                    
                    try await supabase
                        .from("cat_photos")
                        .insert(newPhoto)
                        .execute()
                }
            }
            
            print("✅ Cat and photos uploaded successfully")
            await fetchCats()
            
        } catch {
            print("❌ createCatWithPhotos failed:", error)
        }
    }
    // MARK: - User Collections
    // Dictionary: collection name -> array of photo URLs
    @Published var userCollections: [String: [String]] = [
        "Favorites": [],
        "Cute Cats": [],
        "Funny Cats": []
    ]
    
    // MARK: - Save sheet state
    @Published var showingSaveToCollection: Bool = false
    @Published var selectedPhotoToSave: String? = nil
    
    
    // MARK: - Fetch all cats
    
    func fetchCats() async {
        do {
            var response: [Cat] = try await supabase
                .from("cats")
                .select()
                .order("created_at", ascending: false)
                .execute()
                .value
            
            for i in 0..<response.count {
                do {
                    let image_link: [NewCatPhoto] = try await supabase
                        .from("cat_photos")
                        .select("cat_id, image_url")
                        .eq("cat_id", value: response[i].id.uuidString.lowercased())
                        .execute()
                        .value
                    response[i].image_url = image_link.count > 0 ? image_link[0].image_url : ""
                    debugPrint(response[i].image_url)
                } catch {
                    print("Error finding image for cat \(response[i].id.uuidString.lowercased()) error: \(error)")
                }
            }
            
            self.cats = response
            print("🐾 Loaded \(response.count) cats")
        } catch {
            print("❌ Fetch failed:", error)
        }
    }
    func savePhoto(_ photoURL: String, to collection: String) {
        if userCollections[collection] != nil {
            userCollections[collection]?.append(photoURL)
        } else {
            userCollections[collection] = [photoURL]
        }
        print("Saved photo \(photoURL) to collection \(collection)")
    }
}

