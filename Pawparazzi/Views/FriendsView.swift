//
//  FriendsView.swift
//  Pawparazzi
//
//  Created by Lauren Hsueh on 11/18/25.
//

import SwiftUI

struct FriendsView: View {
    @State private var searchText: String = ""
    @State private var selectedSegment: FollowSegment = .following
    
    // Demo data for now – can be wired to real backend later.
    private let users: [FollowUser] = [
        FollowUser(handle: "@meowmaster_99", isFollowing: true, isFollower: true),
        FollowUser(handle: "@whiskerwatcher", isFollowing: true, isFollower: false),
        FollowUser(handle: "@nyc_catspotter", isFollowing: true, isFollower: true),
        FollowUser(handle: "@purrfect_photos", isFollowing: true, isFollower: false),
        FollowUser(handle: "@feline.friend", isFollowing: true, isFollower: false),
        FollowUser(handle: "@catlover4life", isFollowing: true, isFollower: false)
    ]
    
    private var followingCount: Int {
        users.filter { $0.isFollowing }.count
    }
    
    private var followersCount: Int {
        users.filter { $0.isFollower }.count
    }
    
    private var filteredUsers: [FollowUser] {
        let base: [FollowUser]
        switch selectedSegment {
        case .following:
            base = users.filter { $0.isFollowing }
        case .followers:
            base = users.filter { $0.isFollower }
        }
        
        guard !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return base
        }
        
        return base.filter { $0.handle.localizedCaseInsensitiveContains(searchText) }
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
                        FollowRow(user: user)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                
                Spacer(minLength: 24)
            }
        }
        .background(AppColors.background.ignoresSafeArea())
    }
}

// MARK: - Models

private enum FollowSegment {
    case following
    case followers
}

private struct FollowUser: Identifiable {
    let id = UUID()
    let handle: String
    let isFollowing: Bool
    let isFollower: Bool
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
    let user: FollowUser
    
    var body: some View {
        HStack(spacing: 12) {
            // Avatar placeholder
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
                
                Text(String(user.handle.dropFirst().prefix(1)).uppercased())
                    .font(.custom("Inter-Regular", size: 20))
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
            }
            .frame(width: 48, height: 48)
            
            Text(user.handle)
                .font(.custom("Inter-Regular", size: 16))
                .foregroundStyle(.primary)
            
            Spacer()
            
            Text(user.isFollowing ? "Following" : "Follow")
                .font(.custom("Inter-Regular", size: 13))
                .foregroundStyle(AppColors.mutedText)
                .padding(.horizontal, 18)
                .padding(.vertical, 6)
                .background(
                    Capsule()
                        .stroke(AppColors.fieldBorder, lineWidth: 1)
                )
        }
        .padding(.vertical, 2)
    }
}

#Preview {
    FriendsView()
}
