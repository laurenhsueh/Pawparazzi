import SwiftUI

struct UserView: View {
    @StateObject private var manager = CatStore.shared
    @StateObject private var userStore = UserStore.shared
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                
                // MARK: - Header
                HStack(alignment: .center) {
                    Text("Account")
                        .font(.custom("AnticDidone-Regular", size: 40))
                    
                    Spacer()
                    
                    Button(action: {
                        Task {
                            await userStore.loadProfile()
                        }
                    }) {
                        Image(systemName: "arrow.clockwise")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundStyle(.primary)
                    }
                    .buttonStyle(.plain)
                    .disabled(userStore.isLoading)
                }
                .padding(.top, 24)
                
                // MARK: - Profile + Collections Card
                VStack(alignment: .leading, spacing: 24) {
                    
                    // Profile header inside card
                    HStack(alignment: .center, spacing: 16) {
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
                            
                            if let urlString = userStore.profile?.avatarUrl,
                               let url = URL(string: urlString) {
                                AsyncImage(url: url) { image in
                                    image
                                        .resizable()
                                        .scaledToFill()
                                } placeholder: {
                                    ProgressView()
                                }
                                .clipShape(Circle())
                            } else {
                                Text(displayInitials)
                                    .font(.custom("Inter-Regular", size: 32))
                                    .fontWeight(.bold)
                                    .foregroundStyle(.white)
                            }
                        }
                        .frame(width: 84, height: 84)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text(displayUsername)
                                .font(.custom("Inter-Regular", size: 20))
                                .fontWeight(.semibold)
                            
                            VStack(alignment: .leading, spacing: 6) {
                                HStack(spacing: 8) {
                                    Image(systemName: "mappin.and.ellipse")
                                        .font(.system(size: 14))
                                        .foregroundStyle(AppColors.mutedText)
                                    
                                    Text(userStore.profile?.location ?? "Location unknown")
                                        .font(.custom("Inter-Regular", size: 14))
                                        .foregroundStyle(AppColors.mutedText)
                                }
                                
                                HStack(spacing: 8) {
                                    Image(systemName: "text.justify.left")
                                        .font(.system(size: 14))
                                        .foregroundStyle(AppColors.mutedText)
                                    
                                    Text(userStore.profile?.bio ?? "Add a short bio to share your vibe.")
                                        .font(.custom("Inter-Regular", size: 14))
                                        .foregroundStyle(AppColors.mutedText)
                                        .lineLimit(2)
                                }
                            }
                        }
                    }
                    
                    if let email = userStore.profile?.email {
                        HStack {
                            Image(systemName: "envelope")
                                .foregroundStyle(AppColors.mutedText)
                            Text(email)
                                .font(.custom("Inter-Regular", size: 14))
                                .foregroundStyle(AppColors.mutedText)
                        }
                    }
                    
                    if let error = userStore.errorMessage {
                        Text(error)
                            .font(.custom("Inter-Regular", size: 12))
                            .foregroundColor(.red)
                    }
                    
                    // Collections header
                    HStack(alignment: .firstTextBaseline) {
                        Text("Collections")
                            .font(.custom("Inter-Regular", size: 16))
                            .fontWeight(.semibold)
                        
                        Spacer()
                        
                        Text("New")
                            .font(.custom("Inter-Regular", size: 13))
                            .foregroundStyle(AppColors.accent)
                    }
                    
                    // Collections list
                    if manager.userCollections.isEmpty {
                        EmptyCollectionsCard()
                    } else {
                        VStack(spacing: 12) {
                            ForEach(manager.userCollections.keys.sorted(), id: \.self) { name in
                                let photos = manager.userCollections[name] ?? []
                                CollectionRow(
                                    title: name,
                                    count: photos.count,
                                    photoURLs: photos
                                )
                            }
                        }
                    }
                }
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(AppColors.cardBackground)
                        .shadow(color: AppColors.cardShadow.opacity(0.25), radius: 12, x: 0, y: 6)
                )
                
                Spacer(minLength: 24)
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 32)
            .task {
                await userStore.loadProfile()
            }
        }
        .background(AppColors.background.ignoresSafeArea())
        .overlay {
            if userStore.isLoading {
                ProgressView()
                    .padding()
                    .background(.ultraThinMaterial)
                    .cornerRadius(12)
            }
        }
    }
    
    private var displayUsername: String {
        guard let username = userStore.profile?.username else {
            return "@pawparazzi_user"
        }
        return "@\(username)"
    }
    
    private var displayInitials: String {
        guard let username = userStore.profile?.username else { return "🐾" }
        return String(username.prefix(2)).uppercased()
    }
}

// MARK: - Collection Row

private struct CollectionRow: View {
    let title: String
    let count: Int
    let photoURLs: [String]
    
    var body: some View {
        HStack(spacing: 16) {
            // Thumbnails
            HStack(spacing: -8) {
                let previewURLs = Array(photoURLs.prefix(3))
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
            
            // Title + subtitle
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

// MARK: - Empty Collections Placeholder

private struct EmptyCollectionsCard: View {
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

#Preview {
    UserView()
}
