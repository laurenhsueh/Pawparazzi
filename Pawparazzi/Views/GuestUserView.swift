import SwiftUI

struct GuestUserView: View {
    let username: String
    
    @Environment(\.dismiss) private var dismiss
    @StateObject private var profileModel = GuestUserViewModel()
    @StateObject private var collectionsModel = CollectionsViewModel()
    @StateObject private var userStore = UserStore.shared
    @State private var selectedCollection: CollectionPreview?
    
    private var followAction: ProfileSummaryCard.PrimaryAction? {
        guard profileModel.profile != nil else { return nil }
        if userStore.profile?.username == username { return nil }
        let title = profileModel.profile?.isFollowed == true ? "Following" : "Follow"
        return .init(
            title: title,
            isLoading: profileModel.isMutatingFollow,
            isEnabled: !profileModel.isMutatingFollow,
            action: {
                Task {
                    await profileModel.toggleFollow()
                }
            }
        )
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                header
                
                ProfileSummaryCard(
                    profile: profileModel.profile,
                    isLoading: profileModel.isLoading,
                    errorMessage: profileModel.errorMessage,
                    action: followAction
                )
                
                CollectionsSection(
                    title: "Collections",
                    collections: collectionsModel.collections,
                    isLoading: collectionsModel.isLoading,
                    errorMessage: collectionsModel.errorMessage,
                    showsCreateButton: false,
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
            await loadData(force: false)
        }
        .task(id: username) {
            await loadData(force: true)
        }
        .task {
            if userStore.profile == nil {
                await userStore.loadProfile()
            }
        }
        .overlay(alignment: .center) {
            if profileModel.isLoading && profileModel.profile == nil {
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
    }
    
    private var header: some View {
        HStack(spacing: 12) {
            Button {
                dismiss()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(.primary)
            }
            .buttonStyle(.plain)
            
            Text("@\(username)")
                .font(.custom("AnticDidone-Regular", size: 28))
            
            Spacer()
        }
        .padding(.top, 16)
    }
    
    // MARK: - Loading
    
    private func loadData(force: Bool) async {
        async let profileTask = profileModel.load(username: username, force: force)
        async let collectionsTask = collectionsModel.loadCollections(for: username, force: force)
        _ = await (profileTask, collectionsTask)
    }
}

// MARK: - ViewModel

@MainActor
final class GuestUserViewModel: ObservableObject {
    @Published private(set) var profile: UserProfile?
    @Published var isLoading: Bool = false
    @Published var isMutatingFollow: Bool = false
    @Published var errorMessage: String?
    
    private let api: PawparazziAPI
    private var loadTask: Task<Void, Never>?
    
    init(api: PawparazziAPI = .shared) {
        self.api = api
    }
    
    func load(username: String, force: Bool) async {
        if let loadTask {
            await loadTask.value
            if !force && profile?.username == username {
                return
            }
        }
        
        let task = Task { [weak self] in
            guard let self else { return }
            await self.performLoad(username: username)
        }
        loadTask = task
        await task.value
        loadTask = nil
    }
    
    private func performLoad(username: String) async {
        guard !isLoading else { return }
        isLoading = true
        defer { isLoading = false }
        
        do {
            let response = try await api.fetchProfile(username: username)
            profile = response.user
            errorMessage = nil
        } catch is CancellationError {
            // swallow cancellation
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func toggleFollow() async {
        guard let username = profile?.username else { return }
        guard !isMutatingFollow else { return }
        
        isMutatingFollow = true
        defer { isMutatingFollow = false }
        
        do {
            let action = profile?.isFollowed == true ? "unfollow" : nil
            _ = try await api.followUser(username: username, action: action)
            await load(username: username, force: true)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

#Preview {
    GuestUserView(username: "meowmaster_99")
}
