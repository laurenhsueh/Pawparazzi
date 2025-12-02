//
//  FriendsView.swift
//  Pawparazzi
//
//  Created by Lauren Hsueh on 11/18/25.
//

import SwiftUI

struct FriendsView: View {
    @StateObject private var store = FollowersStore()
    @State private var searchText: String = ""
    @State private var selectedSegment: FollowSegment = .following
    
    private var followingCount: Int {
        store.following.count
    }
    
    private var followersCount: Int {
        store.followers.count
    }
    
    private var filteredUsers: [FollowerSummary] {
        let base: [FollowerSummary] = selectedSegment == .following ? store.following : store.followers
        guard !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return base
        }
        return base.filter { $0.username.localizedCaseInsensitiveContains(searchText) }
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                
                // MARK: - Header
                Text("Follows")
                    .font(.custom("AnticDidone-Regular", size: 40))
                    .padding(.top, 24)
                    .padding(.horizontal, 16)
                
                // MARK: - Search
                SearchBar(text: $searchText, placeholder: "Search Follows")
                    .padding(.top, -8)
                
                // MARK: - Segmented Control
                FollowSegmentControl(
                    selectedSegment: $selectedSegment,
                    followingCount: followingCount,
                    followersCount: followersCount
                )
                .padding(.horizontal, 16)
                
                // MARK: - Follow List
                VStack(spacing: 16) {
                    ForEach(filteredUsers) { user in
                        let actionTitle = selectedSegment == .following ? "Unfollow" : "Follow"
                        FollowRow(
                            user: user,
                            isFollowingSegment: selectedSegment == .following,
                            actionTitle: actionTitle,
                            action: {
                                Task {
                                    let action = selectedSegment == .following ? "unfollow" : nil
                                    await store.toggleFollow(username: user.username, action: action)
                                }
                            }
                        )
                        .task {
                            if selectedSegment == .following {
                                await store.loadMoreFollowingIfNeeded(current: user)
                            } else {
                                await store.loadMoreFollowersIfNeeded(current: user)
                            }
                        }
                    }
                    
                    if storeErrorMessage != nil {
                        Text(storeErrorMessage ?? "")
                            .font(.custom("Inter-Regular", size: 12))
                            .foregroundColor(.red)
                    }
                    
                    if isCurrentSegmentLoading {
                        ProgressView()
                            .padding(.vertical, 12)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                
                Spacer(minLength: 24)
            }
        }
        .background(AppColors.background.ignoresSafeArea())
        .refreshable {
            await store.refresh()
        }
        .task {
            await store.refresh()
        }
    }
    
    private var storeErrorMessage: String? {
        store.errorMessage
    }
    
    private var isCurrentSegmentLoading: Bool {
        selectedSegment == .following ? store.isLoadingFollowing : store.isLoadingFollowers
    }
}

private enum FollowSegment {
    case following
    case followers
}

// MARK: - Segmented Control

private struct FollowSegmentControl: View {
    @Binding var selectedSegment: FollowSegment
    let followingCount: Int
    let followersCount: Int
    
    var body: some View {
        HStack(spacing: 0) {
            segmentButton(
                segment: .following,
                label: "Followed (\(followingCount))",
                systemImage: "person.2.fill",
                isLeading: true
            )
            
            segmentButton(
                segment: .followers,
                label: "Followers",
                systemImage: "person.crop.circle.badge.plus",
                isLeading: false
            )
        }
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(AppColors.fieldBorder, lineWidth: 1)
        )
    }
    
    @ViewBuilder
    private func segmentButton(
        segment: FollowSegment,
        label: String,
        systemImage: String,
        isLeading: Bool
    ) -> some View {
        let isSelected = selectedSegment == segment
        
        Button {
            selectedSegment = segment
        } label: {
            HStack(spacing: 8) {
                Image(systemName: systemImage)
                    .font(.system(size: 14, weight: .semibold))
                
                Text(label)
                    .font(.custom("Inter-Regular", size: 14))
                    .fontWeight(.semibold)
            }
            .foregroundStyle(isSelected ? Color.white : .primary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .background(
                Group {
                    if isSelected {
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(AppColors.primaryAction)
                    } else {
                        Color.clear
                    }
                }
            )
        }
        .buttonStyle(.plain)
        .clipShape(
            RoundedRectangle(
                cornerRadius: 16,
                style: .continuous
            )
        )
    }
}

// MARK: - Row

private struct FollowRow: View {
    let user: FollowerSummary
    let isFollowingSegment: Bool
    let actionTitle: String
    let action: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(red: 1.0, green: 0.65, blue: 0.50),
                                Color(red: 1.0, green: 0.40, blue: 0.50)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                
                if let avatar = user.avatarUrl,
                   let url = URL(string: avatar) {
                    AsyncImage(url: url) { image in
                        image
                            .resizable()
                            .scaledToFill()
                    } placeholder: {
                        ProgressView()
                    }
                    .clipShape(Circle())
                } else {
                    Text(String(user.username.prefix(1)).uppercased())
                        .font(.custom("Inter-Regular", size: 20))
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)
                }
            }
            .frame(width: 48, height: 48)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("@\(user.username)")
                    .font(.custom("Inter-Regular", size: 16))
                    .foregroundStyle(.primary)
                if let bio = user.bio {
                    Text(bio)
                        .font(.custom("Inter-Regular", size: 12))
                        .foregroundStyle(AppColors.mutedText)
                        .lineLimit(1)
                }
            }
            
            Spacer()
            
            Button(action: action) {
                Text(actionTitle)
                    .font(.custom("Inter-Regular", size: 13))
                    .foregroundStyle(AppColors.mutedText)
                    .padding(.horizontal, 18)
                    .padding(.vertical, 6)
                    .background(
                        Capsule()
                            .stroke(AppColors.fieldBorder, lineWidth: 1)
                    )
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, 2)
    }
}

#Preview {
    FriendsView()
}
