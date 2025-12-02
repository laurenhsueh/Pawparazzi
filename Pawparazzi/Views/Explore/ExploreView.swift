import SwiftUI

struct ExploreView: View {
    @StateObject private var manager = SupabaseManager.shared
    @State private var searchText: String = ""
    @State private var categorizedTags: [String: [String]] = TagData.categorizedTags
    @State private var quickTags: [String] = TagData.quickTags
    @State private var selectedFilterTag: String? = nil
        @State private var showingFilteredFeed: Bool = false

    var body: some View {
        if showingFilteredFeed, let tag = selectedFilterTag {
            FilteredTagFeedView(tag: tag, cats: manager.cats) {
                // Back button tapped
                showingFilteredFeed = false
                selectedFilterTag = nil
            }
        } else {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    
                    // MARK: - Header
                    Text("Find some cats")
                        .font(.custom("AnticDidone-Regular", size: 40))
                        .padding(.horizontal, 16)
                    
                    // MARK: - Search Bar
                    SearchBar(text: $searchText, placeholder: "The most stinky cat")
                    
                    // MARK: - Quick Tags
                    HStack(spacing: 12) {
                        
                        Text("Explore")
                            .font(.custom("Inter-Regular", size: 14))
                            .foregroundStyle(.primary)
                                .font(.custom("Inter-Regular", size: 14))
                                .foregroundStyle(.primary)
                        Spacer()
                        let allTags: [String] = manager.cats.flatMap { cat in
                            cat.tags?.values.map { String($0) } ?? []
                        }
                        let uniqueTags = Array(Set(allTags)).shuffled().prefix(3)  // 3 random tags
                        
                        ForEach(uniqueTags, id: \.self) { tag in
                            Text(tag)
                                .tagOutline(isSelected: selectedFilterTag == tag)
                                .onTapGesture { toggleFilterTag(tag) }
                        }
                        
                    }
                    .padding(.horizontal, 16)
                    
                    // MARK: - Sections by Tag
                    let catsByTag = groupCatsByTag(cats: manager.cats)
                    let tagList = catsByTag.keys.sorted()
                    
                    ForEach(tagList, id: \.self) { tag in
                        // Skip tags not matching the filter
                        if let filter = selectedFilterTag, filter != tag {
                            EmptyView()
                        } else {
                            VStack(alignment: .leading, spacing: 12) {
                                
                                // Category title WITH > and tagOutline styling
                                HStack {
                                    Text("\(tag) >")
                                        .tagOutline(isSelected: selectedFilterTag == tag)
                                        .onTapGesture {
                                            selectedFilterTag = tag
                                            showingFilteredFeed = true }
                                    Spacer()
                                }
                                .padding(.leading, 16)
                                
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 12) {
                                        ForEach(catsByTag[tag] ?? []) { cat in
                                            if let photoURL = cat.image_url,
                                               let url = URL(string: photoURL) {
                                                
                                                AsyncImage(url: url) { image in
                                                    image
                                                        .resizable()
                                                        .scaledToFill()
                                                        .frame(width: 132, height: 200)
                                                        .clipped()
                                                        .cornerRadius(12)
                                                } placeholder: {
                                                    Rectangle()
                                                        .fill(Color(.secondarySystemFill))
                                                        .frame(width: 132, height: 200)
                                                        .cornerRadius(12)
                                                }
                                            }
                                        }
                                    }
                                    .padding(.horizontal, 16)
                                }
                            }
                            .padding(.vertical, 10)
                        }
                    }
                }
                .padding(.vertical)
                .task {
                    await manager.fetchCats()
                }
            }
        }
    }
    
    // MARK: - Toggle selected tag filter
    private func toggleFilterTag(_ tag: String) {
        if selectedFilterTag == tag {
            selectedFilterTag = nil  // unselect
        } else {
            selectedFilterTag = tag  // filter by tag
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
