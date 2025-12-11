import SwiftUI

struct ExploreView: View {
    @StateObject private var store = CatStore.shared
    @State private var searchText: String = ""
    @State private var categorizedTags: [String: [String]] = TagData.categorizedTags
    @State private var quickTags: [String] = TagData.quickTags
    @State private var selectedFilterTag: String? = nil
    @State private var showingFilteredFeed: Bool = false

    var body: some View {
        if showingFilteredFeed, let tag = selectedFilterTag {
            FilteredTagFeedView(tag: tag, store: store) {
                showingFilteredFeed = false
                selectedFilterTag = nil
            }
            .task {
                await store.searchCatsImmediately(tags: [tag])
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
                        .onChange(of: searchText, perform: handleSearchTextChange)
                    
                    if store.isSearching && !searchText.isEmpty {
                        ProgressView("Searching…")
                            .padding(.horizontal, 16)
                    }
                    
                    if let error = store.searchError, !error.isEmpty {
                        Text(error)
                            .font(.custom("Inter-Regular", size: 12))
                            .foregroundColor(.red)
                            .padding(.horizontal, 16)
                    }
                    
                    if !store.searchResults.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Search Results")
                                .font(.custom("Inter-Regular", size: 16))
                                .fontWeight(.semibold)
                                .padding(.horizontal, 16)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    ForEach(store.searchResults) { cat in
                                        CatThumbnail(cat: cat)
                                            .onAppear {
                                                Task {
                                                    await store.loadMoreSearchResultsIfNeeded(currentCat: cat)
                                                }
                                            }
                                    }
                                }
                                .padding(.horizontal, 16)
                            }
                        }
                    }
                    
                    // MARK: - Quick Tags
                    HStack(spacing: 12) {
                        
                        Text("Explore")
                            .font(.custom("Inter-Regular", size: 14))
                            .foregroundStyle(.primary)
                        Spacer()
                        let allTags: [String] = store.cats.flatMap { cat in
                            cat.tags
                        }
                        let uniqueTags = Array(Set(allTags)).shuffled().prefix(3)  // 3 random tags
                        
                        ForEach(uniqueTags, id: \.self) { tag in
                            Text(tag)
                                .tagOutline(isSelected: selectedFilterTag == tag)
                                .onTapGesture {
                                    let wasSelected = selectedFilterTag == tag
                                    toggleFilterTag(tag)
                                    guard !wasSelected else { return }
                                    Task {
                                        await store.searchCatsImmediately(tags: [tag])
                                    }
                                }
                        }
                        
                    }
                    .padding(.horizontal, 16)
                    
                    // MARK: - Sections by Tag
                    let catsByTag = groupCatsByTag(cats: store.cats)
                    let tagList = catsByTag.keys.sorted()
                    
                    ForEach(tagList, id: \.self) { tag in
                        if let filter = selectedFilterTag, filter != tag {
                            EmptyView()
                        } else {
                            VStack(alignment: .leading, spacing: 12) {
                                
                                HStack {
                                    Text("\(tag) >")
                                        .tagOutline(isSelected: selectedFilterTag == tag)
                                        .onTapGesture {
                                            selectedFilterTag = tag
                                            showingFilteredFeed = true
                                        }
                                    Spacer()
                                }
                                .padding(.leading, 16)
                                
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 12) {
                                        ForEach(catsByTag[tag] ?? []) { cat in
                                            if let photoURL = cat.imageUrl,
                                               let url = URL(string: photoURL) {
                                                CatImageView(url: url)
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
                    await store.refresh()
                }
            }
        }
    }
    
    // MARK: - Toggle selected tag filter
    private func toggleFilterTag(_ tag: String) {
        if selectedFilterTag == tag {
            selectedFilterTag = nil
            showingFilteredFeed = false
        } else {
            selectedFilterTag = tag
            showingFilteredFeed = true
        }
    }

    private func handleSearchTextChange(_ text: String) {
        let tags = parseTags(from: text)
        store.searchCats(tags: tags)
    }

    private func parseTags(from text: String) -> [String] {
        text
            .split(whereSeparator: { character in
                character == "," || character == " " || character == "#"
            })
            .map { String($0) }
    }

    private func groupCatsByTag(cats: [CatModel]) -> [String: [CatModel]] {
        var dict: [String: [CatModel]] = [:]
        for cat in cats {
            for tag in cat.tags {
                dict[tag, default: []].append(cat)
            }
        }
        return dict
    }
}

private struct CatThumbnail: View {
    let cat: CatModel

    var body: some View {
        VStack(spacing: 8) {
            if let photoURL = cat.imageUrl, let url = URL(string: photoURL) {
                CatImageView(url: url)
            }

            Text(cat.name)
                .font(.custom("Inter-Regular", size: 12))
                .foregroundStyle(AppColors.mutedText)
                .lineLimit(1)
                .frame(width: 132)
        }
    }
}

private struct CatImageView: View {
    let url: URL

    var body: some View {
        AsyncImage(url: url) { phase in
            switch phase {
            case .success(let image):
                image
                    .resizable()
                    .scaledToFill()
                    .frame(width: 132, height: 200)
                    .clipped()
                    .cornerRadius(12)
            case .empty, .failure:
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.secondarySystemFill))
                    .frame(width: 132, height: 200)
            @unknown default:
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.secondarySystemFill))
                    .frame(width: 132, height: 200)
            }
        }
    }
}

#Preview {
    ExploreView()
}

