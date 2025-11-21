//
//  HomeView.swift
//  Pawparazzi
//
//  Created by Lauren Hsueh on 11/18/25.
//
//
import SwiftUI

struct HomeView: View {
    @StateObject private var manager = SupabaseManager.shared
    
    // MARK: - Save to Collection
    @State private var showingSaveToCollection: Bool = false
    @State private var selectedPhotoToSave: String? = nil
    @State private var selectedCollection: String = ""
    @State private var userCollections: [String] = ["Favorites", "Cute Cats", "Funny Cats"] // Default collections
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 20) {
                ForEach(manager.cats.reversed()) { cat in
                    VStack(alignment: .leading, spacing: 8) {
                        // MARK: - Cat Name
                        Text(cat.name)
                            .font(.headline)
                            .padding(.horizontal, 8)
                        
                        // MARK: - Cat Description
                        if let desc = cat.description, !desc.isEmpty {
                            Text(desc)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .padding(.horizontal, 8)
                        }
                        
                        // MARK: - Cat Image with overlay
                        if let photoURL = cat.image_url, let url = URL(string: photoURL) {
                            ZStack(alignment: .topLeading) {
                                AsyncImage(url: url) { image in
                                    image
                                        .resizable()
                                        .scaledToFill()
                                        .frame(maxWidth: .infinity)
                                        .frame(height: 250)
                                        .clipped()
                                        .cornerRadius(12)
                                } placeholder: {
                                    Rectangle()
                                        .fill(Color(.secondarySystemFill))
                                        .frame(height: 250)
                                        .cornerRadius(12)
                                        .overlay(
                                            ProgressView()
                                        )
                                }
                                
                                // MARK: - Tags overlay
                                if let tags = cat.tags, !tags.isEmpty {
                                    HStack(spacing: 6) {
                                        ForEach(Array(tags.keys.sorted()), id: \.self) { key in
                                            if let value = tags[key] {
                                                Text(value)
                                                    .font(.caption)
                                                    .padding(.horizontal, 8)
                                                    .padding(.vertical, 4)
                                                    .background(Color.black.opacity(0.6))
                                                    .foregroundColor(.white)
                                                    .cornerRadius(6)
                                            }
                                        }
                                    }
                                    .padding(20)
                                    .background(
                                        LinearGradient(
                                            gradient: Gradient(colors: [.black.opacity(0.6), .black.opacity(0)]),
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                        .mask(
                                            HStack {
                                                Spacer()
                                                Rectangle()
                                                    .frame(width: 50)
                                            }
                                        )
                                    )
                                }
                                
                                // MARK: - Bottom actions
                                HStack {
                                    VStack(alignment: .leading, spacing: 8) {
                                        HStack(spacing: 16) {
                                            Image(systemName: "heart")
                                            Text("24")
                                            
                                            Image(systemName: "bubble.right")
                                            Text("5")
                                            
                                            Image(systemName: "square.and.arrow.up")
                                        }
                                        .font(.subheadline)
                                        .foregroundColor(.white)
                                    }
                                    Spacer()
                                    
                                    // MARK: - Save Button
                                    Button {
                                        manager.selectedPhotoToSave = photoURL
                                        manager.showingSaveToCollection = true
                                    } label: {
                                        Image(systemName: "bookmark")
                                            .foregroundColor(.white)
                                            .padding(6)
                                            .background(Color.black.opacity(0.5))
                                            .clipShape(RoundedRectangle(cornerRadius: 6))
                                    }
                                }
                                .padding(8)
                                .frame(maxHeight: .infinity, alignment: .bottom)
                            }
                            .padding(.horizontal, 8)
                        }
                    }
                }
            }
            .padding(.vertical)
            .task {
                await manager.fetchCats()
            }
        }
        .sheet(isPresented: $manager.showingSaveToCollection) {
            VStack(spacing: 20) {
                Text("Save Photo to Collection")
                    .font(.headline)
                    .padding(.top)
                
                List {
                    ForEach(manager.userCollections.keys.sorted(), id: \.self) { collection in
                        Button {
                            if let photo = manager.selectedPhotoToSave {
                                manager.savePhoto(photo, to: collection)
                            }
                            manager.showingSaveToCollection = false
                        } label: {
                            Text(collection)
                        }
                    }
                }
                
                Button("Cancel") {
                    manager.showingSaveToCollection = false
                }
                .padding()
            }
        }
    }
    
    // MARK: - Save function
    func savePhotoToCollection() {
        guard let photo = selectedPhotoToSave else { return }
        print("Saved photo \(photo) to collection \(selectedCollection)")
        
        // TODO: Call Supabase to save the photo and collection association
        // e.g., supabase.from("user_collections").insert(...)
    }
}

#Preview {
    HomeView()
}
