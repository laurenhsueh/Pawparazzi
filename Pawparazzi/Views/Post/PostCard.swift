//
//  PostCard.swift
//  Pawparazzi
//
//  Created by Lauren Hsueh on 12/1/25.
//

import SwiftUI

struct PostCard: View {
    let cat: CatModel
    let onProfileTapped: (UserProfile) -> Void
    let onSaveTapped: (CatModel) -> Void
    
    init(
        cat: CatModel,
        onProfileTapped: @escaping (UserProfile) -> Void = { _ in },
        onSaveTapped: @escaping (CatModel) -> Void = { _ in }
    ) {
        self.cat = cat
        self.onProfileTapped = onProfileTapped
        self.onSaveTapped = onSaveTapped
    }

    private let contentWidth = UIScreen.main.bounds.width - 70
    private let contentHeight: CGFloat = 400

    var body: some View {
        VStack {
            VStack(alignment: .leading, spacing: 12) {
                // MARK: - User section
                HStack(alignment: .center) {
                    // Username + profile circle
                    Button {
                        onProfileTapped(cat.poster)
                    } label: {
                        HStack(spacing: 12) {
                            Group {
                                if let avatarUrl = cat.poster.avatarUrl, let url = URL(string: avatarUrl) {
                                    AsyncImage(url: url) { image in
                                        image
                                            .resizable()
                                            .scaledToFill()
                                    } placeholder: {
                                        Color(AppColors.secondarySystemBackground)
                                    }
                                } else {
                                    Color(AppColors.secondarySystemBackground)
                                }
                            }
                            .frame(width: 36, height: 36)
                            .clipShape(Circle())

                            Text("@\(cat.poster.username)")
                                .font(.custom("Slabo13px-Regular", size: 14))
                                .foregroundStyle(AppColors.accent)
                        }
                    }
                    .buttonStyle(.plain)

                    Spacer()

                    // Date pill
                    if let created = cat.createdAt {
                        Text(created.formatted(.dateTime.month(.abbreviated).day()))
                            .font(.custom("Inter-Regular", size: 14))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 4)
                            .background(
                                UnevenRoundedRectangle(
                                    cornerRadii: .init(
                                        topLeading: 8,
                                        bottomLeading: 8,
                                        bottomTrailing: 0,
                                        topTrailing: 0
                                    )
                                )
                                    .fill(AppColors.accent)
                            )
                            .foregroundColor(.white)
                            .offset(x: 18)
                    }
                }
                .frame(width: contentWidth) // ensure it matches card width

                // MARK: - Cat name
                Text(cat.name)
                    .font(.custom("AnticDidone-Regular", size: 28))
                    .foregroundStyle(.primary)

                // MARK: - Description
                if let desc = cat.description, !desc.isEmpty {
                    Text(desc)
                        .font(.custom("Inter-Regular", size: 14))
                        .foregroundStyle(AppColors.mutedText)
                }

                // MARK: - Image + tags
                if let photoURL = cat.imageUrl, let url = URL(string: photoURL) {
                    ZStack(alignment: .bottomLeading) {
                        AsyncImage(url: url) { image in
                            image
                                .resizable()
                                .scaledToFill()
                                .frame(width: contentWidth, height: contentHeight)
                                .clipped()
                                .cornerRadius(12)
                        } placeholder: {
                            Rectangle()
                                .fill(Color(.secondarySystemFill))
                                .frame(width: contentWidth, height: contentHeight)
                                .cornerRadius(12)
                        }

                        // Tags overlay
                        if !cat.tags.isEmpty {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 8) {
                                    ForEach(cat.tags, id: \.self) { value in
                                        Text(value)
                                            .tag()
                                    }
                                }
                                .padding(10)
                            }
                            .background(
                                LinearGradient(
                                    colors: [.clear, .black.opacity(0.2)],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .cornerRadius(12)
                        }
                    }
                }

                // MARK: - Action bar
                HStack(spacing: 22) {
//                    HStack(spacing: 6) {
//                        Image(systemName: "bubble.right")
//                        Text("5")
//                    }

                    Button {
                        Task {
                            if cat.isLiked == true {
                                await CatStore.shared.removeLike(cat)
                            } else {
                                await CatStore.shared.likeCat(cat)
                            }
                        }
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: (cat.isLiked ?? false) ? "heart.fill" : "heart")
                                .foregroundStyle((cat.isLiked ?? false) ? .red : .primary)
                            Text("\(cat.likes)")
                        }
                    }
                    .buttonStyle(.plain)

//                    HStack(spacing: 6) {
//                        Image(systemName: "square.and.arrow.up")
//                    }

                    Spacer()

                    // Save button
                    Button {
                        onSaveTapped(cat)
                    } label: {
                        Image("PawIcon")
                            .padding(6)
                    }
                }
                .font(.custom("Inter-Regular", size: 14))
                .foregroundStyle(.primary)

            }
            .frame(width: contentWidth)
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .background(AppColors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 4))
        .shadow(color: AppColors.cardShadow, radius: 5, x: 0, y: 2)
        .padding(.horizontal, 16)
    }
}
