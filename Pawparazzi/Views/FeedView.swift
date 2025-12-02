//
//  HomeView.swift
//  Pawparazzi
//
//  Created by Lauren Hsueh on 11/18/25.
//
//
import SwiftUI

struct FeedView: View {
    @StateObject private var manager = SupabaseManager.shared
    
    var body: some View {
        VStack(spacing: 0) {

            // MARK: - Top Title
            Text("Feed")
                .font(.custom("AnticDidone-Regular", size: 40))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 24)
                .padding(.top, 16)
                .padding(.bottom, 8)

            // MARK: - Feed Scroll
            ScrollView {
                LazyVStack(spacing: 24) {
                    ForEach(manager.cats) { cat in
                        PostCard(cat: cat)
                    }
                }
                .padding(.vertical, 12)
            }
            .task {
                await manager.fetchCats()
            }
        }
        .background(AppColors.background)
    }
}
#Preview {
    FeedView()
}
