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
    @StateObject private var userStore = UserStore.shared
    @StateObject private var collectionsModel = CollectionsViewModel()
    @State private var selectedCat: CatModel?
    @State private var selectedGuestUsername: String?
    
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
                        PostCard(
                            cat: cat,
                            onProfileTapped: { user in
                                selectedGuestUsername = user.username
                            },
                            onSaveTapped: { cat in
                                selectedCat = cat
                            }
                        )
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
        .task {
            await store.refresh()
            await userStore.loadProfile()
        }
        .sheet(item: $selectedCat, onDismiss: {
            selectedCat = nil
        }) { cat in
            CollectionPickerSheet(
                cat: cat,
                username: userStore.profile?.username,
                model: collectionsModel,
                onAdded: {},
                onCancel: {
                    selectedCat = nil
                }
            )
        }
        .sheet(isPresented: Binding(
            get: { selectedGuestUsername != nil },
            set: { isPresented in
                if !isPresented {
                    selectedGuestUsername = nil
                }
            }
        )) {
            if let username = selectedGuestUsername {
                GuestUserView(username: username)
            }
        }
    }
}
#Preview {
    FeedView()
}
