//
//  FilteredTagFeedView.swift
//  Pawparazzi
//
//  Created by Lauren Hsueh on 12/1/25.
//
import SwiftUI

struct FilteredTagFeedView: View {
    @State private var showFocus = false
    @State private var selectedCat: CatModel?

    let tag: String
    @ObservedObject var store: CatStore
    let onBack: () -> Void   // callback for back button
    
    @State private var searchText: String = ""
    
    var filteredCats: [CatModel] {
        let source = store.searchResults.isEmpty ? store.cats : store.searchResults
        return source.filter { $0.tags.contains(tag) }
    }
    
    // Generate random heights for each cat (80 or 160)
    private func randomHeight() -> CGFloat {
        Bool.random() ? 80 : 160
    }
    
    var body: some View {
        VStack(spacing: 12) {
            // MARK: - Top bar with back button & search
            HStack(spacing: 12) {
                Button(action: onBack) {
                    Image(systemName: "chevron.left")
                        .foregroundStyle(.primary)
                        .font(.system(size: 18, weight: .medium))
                }
                SearchBar(text: $searchText, placeholder: "Search \(tag) cats")
                    .onChange(of: searchText, perform: handleSearchChange)
            }
            
            HStack {
                Text(tag)
                    .font(.custom("AnticDidone-Regular", size: 24))
                Spacer()
            }
            
            // MARK: - Pinterest-style feed
            if store.isSearching {
                ProgressView("Fetching cats…")
                    .padding(.vertical, 32)
            }

            if let error = store.searchError, !error.isEmpty {
                Text(error)
                    .font(.custom("Inter-Regular", size: 12))
                    .foregroundColor(.red)
            }
            
            ScrollView(.vertical, showsIndicators: true) {
                HStack(alignment: .top, spacing: 4) {
                    let columnWidth: CGFloat = 110
                    let columns = 3
                    
                    let columnedCats: [[CatModel]] = {
                        var temp = Array(repeating: [CatModel](), count: columns)
                        for (index, cat) in filteredCats.enumerated() {
                            temp[index % columns].append(cat)
                        }
                        return temp
                    }()
                    
                    ForEach(0..<columns, id: \.self) { colIndex in
                        VStack(spacing: 4) {
                            ForEach(columnedCats[colIndex]) { cat in
                                if let url = URL(string: cat.imageUrl ?? "") {
                                    Button {
                                        selectedCat = cat
                                        showFocus = true
                                    } label: {
                                        CatImage(
                                            url: url,
                                            width: columnWidth,
                                            height: randomHeight(),
                                            focusCat: cat
                                        )
                                    }
                                    .buttonStyle(.plain)
                                    .onAppear {
                                        Task { await store.loadMoreSearchResultsIfNeeded(currentCat: cat) }
                                    }
                                }
                            }
                            .fullScreenCover(isPresented: $showFocus) {
                                if let selectedCat = selectedCat {
                                    PostFocusView(cat: selectedCat)
                                }
                            }
                        }
                    }
                }
                .padding(4)
            }
        }
        .background(AppColors.background)
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}

private extension FilteredTagFeedView {
    func handleSearchChange(_ text: String) {
        let extraTags = text
            .split(whereSeparator: { $0 == " " || $0 == "," || $0 == "#" })
            .map { String($0) }
        let tags = [tag] + extraTags
        store.searchCats(tags: tags)
    }
}
