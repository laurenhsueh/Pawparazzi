import SwiftUI

struct ProfileSummaryCard: View {
    struct PrimaryAction {
        let title: String
        let isLoading: Bool
        let isEnabled: Bool
        let action: () -> Void
    }
    
    let profile: UserProfile?
    let isLoading: Bool
    let errorMessage: String?
    var action: PrimaryAction?
    
    private var displayUsername: String {
        guard let username = profile?.username else { return "@pawparazzi_user" }
        return "@\(username)"
    }
    
    private var displayInitials: String {
        guard let username = profile?.username, let first = username.first else { return "🐾" }
        let second = username.dropFirst().first.map { String($0) } ?? ""
        return "\(String(first).uppercased())\(second.uppercased())"
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack(alignment: .center, spacing: 16) {
                ProfileAvatar(
                    avatarUrl: profile?.avatarUrl,
                    fallbackInitials: displayInitials
                )
                .frame(width: 90, height: 90)
                
                VStack(alignment: .leading, spacing: 10) {
                    Text(displayUsername)
                        .font(.custom("Inter-Regular", size: 22))
                        .fontWeight(.semibold)
                    
                    ProfileMetaRow(
                        systemImage: "mappin.and.ellipse",
                        text: profile?.location ?? "Location unknown"
                    )
                    
                    ProfileMetaRow(
                        systemImage: "text.justify.left",
                        text: profile?.bio ?? "Just spotting cats everyday"
                    )
                    .lineLimit(2)
                }
            }
            
            ProfileStatsRow(
                posts: profile?.postCount ?? 0,
                followers: profile?.followerCount ?? 0,
                following: profile?.followingCount ?? 0
            )
            
            if let action {
                Button(action: action.action) {
                    HStack {
                        Spacer()
                        if action.isLoading {
                            ProgressView()
                        } else {
                            Text(action.title)
                                .font(.custom("Inter-Regular", size: 16))
                                .fontWeight(.semibold)
                        }
                        Spacer()
                    }
                    .padding(.vertical, 12)
                    .background(AppColors.primaryAction)
                    .foregroundStyle(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                }
                .buttonStyle(.plain)
                .disabled(!action.isEnabled)
                .opacity(action.isEnabled ? 1.0 : 0.6)
            }
            
            if let errorMessage {
                Text(errorMessage)
                    .font(.custom("Inter-Regular", size: 12))
                    .foregroundColor(.red)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(AppColors.cardBackground)
                .shadow(color: AppColors.cardShadow.opacity(0.2), radius: 12, x: 0, y: 6)
        )
        .redacted(reason: isLoading && profile == nil ? .placeholder : [])
    }
}

struct ProfileStatsRow: View {
    let posts: Int
    let followers: Int
    let following: Int
    
    var body: some View {
        HStack(spacing: 0) {
            StatColumn(value: posts, label: "Posts")
            
            Divider()
                .frame(width: 1, height: 38)
                .overlay(AppColors.divider)
                .padding(.horizontal, 12)
            
            StatColumn(value: followers, label: "Followers")
            
            Divider()
                .frame(width: 1, height: 38)
                .overlay(AppColors.divider)
                .padding(.horizontal, 12)
            
            StatColumn(value: following, label: "Following")
        }
    }
}

struct CollectionsSection: View {
    let title: String
    let collections: [CollectionPreview]
    let isLoading: Bool
    let errorMessage: String?
    var showsCreateButton: Bool = false
    var onCreateTap: (() -> Void)?
    var onCollectionTap: ((CollectionPreview) -> Void)?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .firstTextBaseline) {
                Text(title)
                    .font(.custom("Inter-Regular", size: 16))
                    .fontWeight(.semibold)
                
                Spacer()
                
                if showsCreateButton, let onCreateTap {
                    Button(action: onCreateTap) {
                        Text("New")
                            .font(.custom("Inter-Regular", size: 13))
                            .foregroundStyle(AppColors.accent)
                    }
                    .buttonStyle(.plain)
                }
            }
            
            if let errorMessage {
                Text(errorMessage)
                    .font(.custom("Inter-Regular", size: 12))
                    .foregroundColor(.red)
            }
            
            if isLoading && collections.isEmpty {
                VStack(spacing: 12) {
                    ForEach(0..<2, id: \.self) { _ in
                        CollectionRowView(title: "Loading…", count: 0, photoURLs: [])
                            .redacted(reason: .placeholder)
                    }
                }
            } else if collections.isEmpty {
                EmptyCollectionsCard()
            } else {
                VStack(spacing: 12) {
                    ForEach(collections) { collection in
                        if let onCollectionTap {
                            Button {
                                onCollectionTap(collection)
                            } label: {
                                CollectionRowView(
                                    title: collection.name,
                                    count: collection.count,
                                    photoURLs: collection.previewURLs
                                )
                            }
                            .buttonStyle(.plain)
                        } else {
                            CollectionRowView(
                                title: collection.name,
                                count: collection.count,
                                photoURLs: collection.previewURLs
                            )
                        }
                    }
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(AppColors.cardBackground)
                .shadow(color: AppColors.cardShadow.opacity(0.2), radius: 12, x: 0, y: 6)
        )
    }
}

struct CollectionRowView: View {
    let title: String
    let count: Int
    let photoURLs: [String]
    
    var body: some View {
        HStack(spacing: 16) {
            HStack(spacing: -8) {
                let previewURLs = Array(photoURLs.prefix(4))
                if previewURLs.isEmpty {
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(AppColors.secondarySystemBackground)
                        .frame(width: 46, height: 46)
                } else {
                    ForEach(previewURLs, id: \.self) { urlString in
                        if let url = URL(string: urlString) {
                            AsyncImage(url: url) { image in
                                image
                                    .resizable()
                                    .scaledToFill()
                            } placeholder: {
                                Rectangle()
                                    .fill(AppColors.secondarySystemBackground)
                            }
                            .frame(width: 46, height: 46)
                            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                    .stroke(Color.white, lineWidth: 1)
                            )
                        }
                    }
                }
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.custom("Inter-Regular", size: 16))
                    .fontWeight(.semibold)
                    .foregroundStyle(.primary)
                
                Text("\(count) cats")
                    .font(.custom("Inter-Regular", size: 13))
                    .foregroundStyle(AppColors.mutedText)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(AppColors.mutedText)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(AppColors.systemBackground)
        )
    }
}

struct EmptyCollectionsCard: View {
    var body: some View {
        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(AppColors.secondarySystemBackground)
                .frame(width: 46, height: 46)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("No collections yet")
                    .font(.custom("Inter-Regular", size: 16))
                    .fontWeight(.semibold)
                    .foregroundStyle(.primary)
                
                Text("Save cats to start a collection")
                    .font(.custom("Inter-Regular", size: 13))
                    .foregroundStyle(AppColors.mutedText)
            }
            
            Spacer()
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(AppColors.systemBackground)
        )
    }
}

struct StatColumn: View {
    let value: Int
    let label: String
    
    var body: some View {
        VStack(spacing: 6) {
            Text("\(value)")
                .font(.custom("Inter-Regular", size: 18))
                .fontWeight(.semibold)
            
            Text(label)
                .font(.custom("Inter-Regular", size: 13))
                .foregroundStyle(AppColors.mutedText)
        }
        .frame(maxWidth: .infinity)
    }
}

private struct ProfileAvatar: View {
    let avatarUrl: String?
    let fallbackInitials: String
    
    var body: some View {
        ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 1.0, green: 0.35, blue: 0.45),
                            Color(red: 0.98, green: 0.58, blue: 0.80)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            
            if let avatarUrl, let url = URL(string: avatarUrl) {
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .scaledToFill()
                } placeholder: {
                    ProgressView()
                }
                .clipShape(Circle())
            } else {
                Text(fallbackInitials)
                    .font(.custom("Inter-Regular", size: 34))
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
            }
        }
    }
}

private struct ProfileMetaRow: View {
    let systemImage: String
    let text: String
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: systemImage)
                .font(.system(size: 14))
                .foregroundStyle(AppColors.mutedText)
            Text(text)
                .font(.custom("Inter-Regular", size: 14))
                .foregroundStyle(AppColors.mutedText)
        }
    }
}
