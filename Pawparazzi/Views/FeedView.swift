//
//  HomeView.swift
//  Pawparazzi
//
//  Created by Lauren Hsueh on 11/18/25.
//
//
import SwiftUI

struct FeedView: View {
    @StateObject private var store = CatStore.shared
    
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
                    ForEach(store.cats) { cat in
                        PostCard(cat: cat)
                            .task {
                                await store.loadMoreIfNeeded(currentCat: cat)
                            }
                    }
                    
                    if store.isLoading && !store.cats.isEmpty {
                        ProgressView()
                            .padding(.vertical, 16)
                    }
                }
                .padding(.vertical, 12)
            }
            .task {
                await store.refresh()
            }
            .refreshable {
                await store.refresh()
            }
            
            if let error = store.errorMessage {
                Text(error)
                    .font(.custom("Inter-Regular", size: 12))
                    .foregroundColor(.red)
                    .padding(.vertical, 8)
            }
        }
        .background(AppColors.background)
    }
}
#Preview {
    FeedView()
}
