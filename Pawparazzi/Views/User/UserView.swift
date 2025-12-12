import SwiftUI

struct UserView: View {
    @StateObject private var userStore = UserStore.shared
    @StateObject private var collectionsModel = CollectionsViewModel()
    @State private var showCreateCollectionSheet = false
    @State private var newCollectionName: String = ""
    @State private var newCollectionError: String?
    @State private var selectedCollection: CollectionPreview?
    @State private var showSettings = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                header
                
                ProfileSummaryCard(
                    profile: userStore.profile,
                    isLoading: userStore.isLoading,
                    errorMessage: userStore.errorMessage,
                    action: nil
                )
                
                CollectionsSection(
                    title: "Collections",
                    collections: collectionsModel.collections,
                    isLoading: collectionsModel.isLoading,
                    errorMessage: collectionsModel.errorMessage,
                    showsCreateButton: true,
                    onCreateTap: {
                        newCollectionError = nil
                        showCreateCollectionSheet = true
                    },
                    onCollectionTap: { collection in
                        selectedCollection = collection
                    }
                )
                
                Spacer(minLength: 24)
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 32)
        }
        .background(AppColors.background.ignoresSafeArea())
        .task {
            await refreshProfile()
        }
        .task(id: userStore.profile?.username) {
            await refreshCollections(force: false)
        }
        .refreshable {
            await refreshProfile()
            await refreshCollections(force: true)
        }
        .overlay(alignment: .center) {
            if userStore.isLoading && userStore.profile == nil {
                ProgressView()
                    .padding()
                    .background(.ultraThinMaterial)
                    .cornerRadius(12)
            }
        }
        .sheet(item: $selectedCollection, onDismiss: {
            selectedCollection = nil
        }) { collection in
            CollectionDetailView(collectionId: collection.id)
        }
        .sheet(isPresented: $showCreateCollectionSheet, onDismiss: {
            newCollectionName = ""
            newCollectionError = nil
        }) {
            NewCollectionSheet(
                name: $newCollectionName,
                error: $newCollectionError,
                isCreating: collectionsModel.isCreating,
                onCreate: createCollection
            )
        }
        .sheet(isPresented: $showSettings) {
            SettingsView()
        }
    }
    
    // MARK: - Sections
    
    private var header: some View {
        HStack(alignment: .center) {
            Text("Account")
                .font(.custom("AnticDidone-Regular", size: 40))
            
            Spacer()
            
             Button(action: {
                 Task {
                     await refreshProfile()
                     await refreshCollections(force: true)
                     showSettings = true
                 }
             }) {
                 Image(systemName: "gearshape.fill")
                     .font(.system(size: 20, weight: .semibold))
                     .foregroundStyle(.primary)
             }
             .buttonStyle(.plain)
             .disabled(userStore.isLoading || collectionsModel.isLoading)
        }
        .padding(.top, 24)
    }
    
    // MARK: - Actions
    
    private func refreshProfile() async {
        await userStore.loadProfile()
    }
    
    private func refreshCollections(force: Bool) async {
        guard let username = userStore.profile?.username else { return }
        await collectionsModel.loadCollections(for: username, force: force)
    }
    
    private func createCollection() {
        let trimmed = newCollectionName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            newCollectionError = "Please enter a collection name."
            return
        }
        guard let username = userStore.profile?.username else {
            newCollectionError = "You need a profile to create collections."
            return
        }
        
        newCollectionError = nil
        Task {
            do {
                try await collectionsModel.createCollection(name: trimmed, for: username)
                newCollectionName = ""
                showCreateCollectionSheet = false
            } catch {
                newCollectionError = error.localizedDescription
            }
        }
    }
}

#Preview {
    UserView()
}
