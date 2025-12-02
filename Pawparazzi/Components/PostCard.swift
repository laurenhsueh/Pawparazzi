//
//  PostCard.swift
//  Pawparazzi
//
//  Created by Lauren Hsueh on 12/1/25.
//

import SwiftUI

struct PostCard: View {
    let cat: Cat

    private let contentWidth = UIScreen.main.bounds.width - 70
    private let contentHeight: CGFloat = 400

    var body: some View {
        VStack {
            VStack(alignment: .leading, spacing: 12) {
                // MARK: - User section
                HStack(alignment: .center) {
                    // Username + profile circle
                    HStack(spacing: 12) {
                        Circle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 36, height: 36)

                        Text("username")
                            .font(.custom("Slabo13px-Regular", size: 14))
                            .foregroundStyle(Color("Secondary"))
                    }

                    Spacer()

                    // Date pill
                    if let created = cat.created_at,
                       let date = ISO8601DateFormatter().date(from: created) {

                        Text(date.formatted(.dateTime.month(.abbreviated).day()))
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
                                .fill(Color("Secondary"))
                            )
                            .foregroundColor(.white)
                            .offset(x: 18)
                    }
                }
                .frame(width: contentWidth) // ensure it matches card width

                // MARK: - Cat name
                Text(cat.name)
                    .font(.custom("AnticDidone-Regular", size: 28))
                    .foregroundStyle(.black)

                // MARK: - Description
                if let desc = cat.description, !desc.isEmpty {
                    Text(desc)
                        .font(.custom("Inter-Regular", size: 14))
                        .foregroundStyle(.black.opacity(0.75))
                }

                // MARK: - Image + tags
                if let photoURL = cat.image_url, let url = URL(string: photoURL) {
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
                        if let tags = cat.tags, !tags.isEmpty {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 8) {
                                    ForEach(Array(tags.keys.sorted()), id: \.self) { key in
                                        if let value = tags[key] {
                                            Text(value)
                                                .tag()
                                        }
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
                    HStack(spacing: 6) {
                        Image(systemName: "bubble.right")
                        Text("5")
                    }

                    HStack(spacing: 6) {
                        Image(systemName: "heart")
                        Text("24")
                    }

                    HStack(spacing: 6) {
                        Image(systemName: "square.and.arrow.up")
                    }

                    Spacer()

                    // Save button
                    Button {
                        SupabaseManager.shared.selectedPhotoToSave = cat.image_url
                        SupabaseManager.shared.showingSaveToCollection = true
                    } label: {
                        Image("PawIcon")
                            .padding(6)
                    }
                }
                .font(.custom("Inter-Regular", size: 14))
                .foregroundStyle(.black.opacity(0.9))

            }
            .frame(width: contentWidth)
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        .padding(.horizontal, 16)
    }
}
