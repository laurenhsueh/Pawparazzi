//
//  FilteredTagFeedView.swift
//  Pawparazzi
//
//  Created by Lauren Hsueh on 12/1/25.
//
import SwiftUI

struct FilteredTagFeedView: View {
    let tag: String
    let cats: [Cat]
    let onBack: () -> Void   // callback for back button
    
    @State private var searchText: String = ""
    
    var filteredCats: [Cat] {
        cats.filter { $0.tags?.values.contains(tag) ?? false }
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
                        .foregroundColor(.black)
                        .font(.system(size: 18, weight: .medium))
                }
                SearchBar(text: $searchText, placeholder: "Search \(tag) cats")
            }
            
            HStack {
                Text(tag)
                    .font(.custom("AnticDidone-Regular", size: 24))
                Spacer()
            }
            
            // MARK: - Pinterest-style feed
            ScrollView(.vertical, showsIndicators: true) {
                HStack(alignment: .top, spacing: 4) {
                    let columnWidth: CGFloat = 110
                    let columns = 3
                    
                    // Split images into 3 columns
                    let columnedCats: [[Cat]] = {
                        var temp = Array(repeating: [Cat](), count: columns)
                        for (index, cat) in filteredCats.enumerated() {
                            temp[index % columns].append(cat)
                        }
                        return temp
                    }()
                    
                    ForEach(0..<columns, id: \.self) { colIndex in
                        VStack(spacing: 4) {
                            ForEach(columnedCats[colIndex]) { cat in
                                if let photoURL = cat.image_url, let url = URL(string: photoURL) {
                                    AsyncImage(url: url) { image in
                                        image
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: columnWidth, height: randomHeight())
                                            .clipped()
                                            .cornerRadius(12)
                                    } placeholder: {
                                        Rectangle()
                                            .fill(Color(.secondarySystemFill))
                                            .frame(width: columnWidth, height: randomHeight())
                                            .cornerRadius(12)
                                    }
                                }
                            }
                        }
                    }
                }
                .padding(4)
            }
        }
        .background(Color(.systemBackground))
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}
