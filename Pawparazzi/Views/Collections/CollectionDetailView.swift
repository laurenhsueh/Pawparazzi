//
//  CollectionDetailView.swift
//  Pawparazzi
//
//  Created by ChatGPT on 12/11/25.
//

import SwiftUI

struct CollectionDetailView: View {
    let collectionId: UUID
    var onBack: (() -> Void)?
    var onCatSelected: ((CatModel) -> Void)?

    @Environment(\.dismiss) private var dismiss
    @StateObject private var store = CollectionStore()

    private let columns: [GridItem] = Array(repeating: GridItem(.flexible(), spacing: 8), count: 3)

    var body: some View {
        VStack(spacing: 16) {
            header
                .padding(.horizontal, 16)

            collectionMeta
                .padding(.horizontal, 16)

            if store.isLoading && store.cats.isEmpty {
                ProgressView("Loading collection…")
                    .padding(.top, 24)
            }

            if let error = store.errorMessage {
                Text(error)
                    .font(.custom("Inter-Regular", size: 12))
                    .foregroundStyle(Color.red)
                    .padding(.horizontal, 16)
            }

            ScrollView {
                LazyVGrid(columns: columns, alignment: .leading, spacing: 8) {
                    ForEach(store.cats) { cat in
                        CollectionCatTile(cat: cat, height: tileHeight(for: cat))
                            .onTapGesture {
                                onCatSelected?(cat)
                            }
                            .onAppear {
                                Task {
                                    await store.loadMoreIfNeeded(currentCat: cat, collectionId: collectionId)
                                }
                            }
                    }
                }
                .padding(.horizontal, 12)
                .padding(.bottom, 24)
            }
        }
        .background(AppColors.background)
        .task(id: collectionId) {
            await store.refresh(id: collectionId)
        }
    }

    private var header: some View {
        HStack(spacing: 12) {
            Button {
                if let onBack {
                    onBack()
                } else {
                    dismiss()
                }
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(.primary)
            }

            Text(store.collection?.name ?? "Collection")
                .font(.custom("AnticDidone-Regular", size: 28))
                .lineLimit(1)
                .truncationMode(.tail)
            Spacer()
        }
    }

    private var collectionMeta: some View {
        VStack(alignment: .leading, spacing: 6) {
            if let description = store.collection?.description, !description.isEmpty {
                Text(description)
                    .font(.custom("Inter-Regular", size: 14))
                    .foregroundStyle(AppColors.mutedText)
            }

            HStack(spacing: 8) {
                if let owner = store.collection?.owner.username {
                    Text("@\(owner)")
                }
                if let count = store.collection?.catCount {
                    Text("\(count) cats")
                } else {
                    Text("\(store.cats.count) cats")
                }
            }
            .font(.custom("Inter-Regular", size: 12))
            .foregroundStyle(AppColors.mutedText)
        }
    }

    private func tileHeight(for cat: CatModel) -> CGFloat {
        // Stable pseudo-random heights to mimic a masonry grid
        let hash = abs(cat.id.uuidString.hashValue)
        return hash % 3 == 0 ? 210 : (hash % 2 == 0 ? 160 : 130)
    }
}

private struct CollectionCatTile: View {
    let cat: CatModel
    let height: CGFloat

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            if let photoURL = cat.imageUrl, let url = URL(string: photoURL) {
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .scaledToFill()
                } placeholder: {
                    Rectangle()
                        .fill(Color(.secondarySystemFill))
                }
                .frame(height: height)
                .frame(maxWidth: .infinity)
                .clipped()
                .cornerRadius(12)
            }

            Text(cat.name)
                .font(.custom("Inter-Regular", size: 12))
                .foregroundStyle(AppColors.mutedText)
                .lineLimit(1)
        }
    }
}
