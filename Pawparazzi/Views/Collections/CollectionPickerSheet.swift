import SwiftUI

struct CollectionPickerSheet: View {
    let cat: CatModel
    let username: String?
    @ObservedObject var model: CollectionsViewModel
    let onAdded: () -> Void
    let onCancel: () -> Void
    
    @State private var localError: String?
    @State private var isAdding: UUID?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Save to Collection")
                    .font(.custom("Inter-Regular", size: 18))
                    .fontWeight(.semibold)
                Spacer()
                Button("Cancel", action: onCancel)
                    .font(.custom("Inter-Regular", size: 14))
            }
            
            if let localError {
                Text(localError)
                    .font(.custom("Inter-Regular", size: 12))
                    .foregroundColor(.red)
            } else if let message = model.errorMessage {
                Text(message)
                    .font(.custom("Inter-Regular", size: 12))
                    .foregroundColor(.red)
            }
            
            ZStack(alignment: .top) {
                if model.collections.isEmpty {
                    VStack(spacing: 12) {
                        Spacer(minLength: 0)
                        
                        if model.isLoading {
                            VStack(spacing: 10) {
                                ProgressView()
                                Text("Loading your collections...")
                                    .font(.custom("Inter-Regular", size: 14))
                                    .foregroundStyle(AppColors.mutedText)
                            }
                            .frame(maxWidth: .infinity)
                        } else {
                            Text("No collections yet. Create one first.")
                                .font(.custom("Inter-Regular", size: 14))
                                .foregroundStyle(AppColors.mutedText)
                        }
                        
                        Spacer(minLength: 0)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ScrollView {
                        VStack(spacing: 12) {
                            ForEach(model.collections) { collection in
                                Button {
                                    add(cat: cat, to: collection)
                                } label: {
                                    HStack(spacing: 12) {
                                        HStack(spacing: -8) {
                                            let previewURLs = Array(collection.previewURLs.prefix(3))
                                            if previewURLs.isEmpty {
                                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                                    .fill(AppColors.secondarySystemBackground)
                                                    .frame(width: 46, height: 46)
                                            } else {
                                                ForEach(previewURLs, id: \.self) { urlString in
                                                    if let url = URL(string: urlString) {
                                                        AsyncImage(url: url) { image in
                                                            image.resizable().scaledToFill()
                                                        } placeholder: {
                                                            Rectangle().fill(AppColors.secondarySystemBackground)
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
                                            Text(collection.name)
                                                .font(.custom("Inter-Regular", size: 16))
                                                .fontWeight(.semibold)
                                                .foregroundStyle(.primary)
                                            
                                            Text("\(collection.count) cats")
                                                .font(.custom("Inter-Regular", size: 13))
                                                .foregroundStyle(AppColors.mutedText)
                                        }
                                        
                                        Spacer()
                                        
                                        if isAdding == collection.id {
                                            ProgressView()
                                        } else {
                                            Image(systemName: "plus.circle.fill")
                                                .foregroundStyle(AppColors.accent)
                                        }
                                    }
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 12)
                                    .background(
                                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                                            .fill(AppColors.systemBackground)
                                    )
                                }
                                .buttonStyle(.plain)
                                .disabled(isAdding != nil)
                            }
                        }
                    }
                }
            }
            Spacer(minLength: 0)
        }
        .padding(20)
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
        .overlay(alignment: .bottom) {
            if model.isLoading && !model.collections.isEmpty {
                HStack(spacing: 8) {
                    ProgressView()
                    Text("Refreshing collections...")
                        .font(.custom("Inter-Regular", size: 12))
                        .foregroundStyle(AppColors.mutedText)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(.thinMaterial)
                .clipShape(Capsule())
                .padding(.bottom, 8)
                .transition(.opacity)
            }
        }
        .animation(.none, value: model.isLoading)
        .animation(.none, value: model.collections)
        .task {
            await loadCollectionsIfNeeded()
        }
    }
    
    private func loadCollectionsIfNeeded() async {
        guard let username else {
            localError = "Please log in to save to a collection."
            return
        }
        await model.loadCollections(for: username, force: true)
    }
    
    private func add(cat: CatModel, to collection: CollectionPreview) {
        guard let username else {
            localError = "Please log in to save to a collection."
            return
        }
        localError = nil
        isAdding = collection.id
        Task {
            do {
                try await model.addCat(cat.id, to: collection.id)
                await MainActor.run {
                    isAdding = nil
                    onAdded()
                    onCancel()
                }
                
                // Refresh in the background so the sheet can close instantly.
                await model.loadCollections(for: username, force: true)
            } catch {
                await MainActor.run {
                    isAdding = nil
                    localError = error.localizedDescription
                }
            }
        }
    }
}
