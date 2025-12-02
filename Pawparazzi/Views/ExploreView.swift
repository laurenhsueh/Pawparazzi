//
//  ExploreView.swift
//  Pawparazzi
//
//  Created by Lauren Hsueh on 11/18/25.
//
import SwiftUI

struct ExploreView: View {
    @StateObject private var manager = SupabaseManager.shared
    @State private var searchText: String = ""
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                
                // MARK: - Header
                Text("Find some cats")
                    .font(.largeTitle)
                    .bold()
                    .padding(.horizontal)
                
                // MARK: - Search Bar
                TextField("Search for a cat", text: $searchText)
                    .padding(12)
                    .background(Color(.secondarySystemFill))
                    .cornerRadius(12)
                    .padding(.horizontal)
                
                // MARK: - Quick Tags
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        let allTags: [String] = manager.cats.flatMap { cat in
                            cat.tags?.values.map { String($0) } ?? []
                        }
                        let uniqueTags = Array(Set(allTags))
                        
                        ForEach(uniqueTags, id: \.self) { tag in
                            Text(tag)
                                .font(.subheadline)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color.blue.opacity(0.2))
                                .foregroundColor(.blue)
                                .cornerRadius(10)
                        }
                    }
                    .padding(.horizontal)
                }
                
                // MARK: - Sections by tag
                let catsByTag = groupCatsByTag(cats: manager.cats)
                
                ForEach(catsByTag.keys.sorted(), id: \.self) { tag in
                    VStack(alignment: .leading, spacing: 8) {
                        Text(tag)
                            .font(.headline)
                            .padding(.horizontal)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(catsByTag[tag] ?? []) { cat in
                                    if let photoURL = cat.image_url, let url = URL(string: photoURL) {
                                        AsyncImage(url: url) { image in
                                            image
                                                .resizable()
                                                .scaledToFill()
                                                .frame(width: 120, height: 120)
                                                .clipped()
                                                .cornerRadius(12)
                                        } placeholder: {
                                            Rectangle()
                                                .fill(Color(.secondarySystemFill))
                                                .frame(width: 120, height: 120)
                                                .cornerRadius(12)
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    .padding(.vertical, 8)
                }
            }
            .padding(.vertical)
            .task {
                await manager.fetchCats()
            }
        }
    }
    
    // MARK: - Group cats by tag
    private func groupCatsByTag(cats: [Cat]) -> [String: [Cat]] {
        var dict: [String: [Cat]] = [:]
        for cat in cats {
            guard let tags = cat.tags else { continue }
            for tag in tags.values {
                dict[tag, default: []].append(cat)
            }
        }
        return dict
    }
}

#Preview {
    ExploreView()
}

