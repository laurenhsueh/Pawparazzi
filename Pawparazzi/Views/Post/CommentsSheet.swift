//
//  CommentsSheet.swift
//  Pawparazzi
//
//  Created by Lauren Hsueh on 12/11/25.
//


import SwiftUI

struct CommentsSheet: View {
    let cat: CatModel
    
    @State private var commentText = ""
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 0) {
            
            // Grabber bar (like Instagram)
            Capsule()
                .fill(Color.gray.opacity(0.4))
                .frame(width: 40, height: 5)
                .padding(.top, 12)
            
            // Title
            Text("Comments")
                .font(.headline)
                .padding(.top, 8)
            
            Divider().padding(.vertical, 8)
            
            // MARK: - Comments List
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
//                    ForEach(cat.comments ?? [], id: \.id) { comment in
//                        HStack(alignment: .top, spacing: 12) {
//                            
//                            // Profile avatar
//                            AsyncImage(url: URL(string: comment.user.avatarUrl ?? "")) { image in
//                                image.resizable().scaledToFill()
//                            } placeholder: {
//                                Color.gray.opacity(0.3)
//                            }
//                            .frame(width: 36, height: 36)
//                            .clipShape(Circle())
//                            
//                            // Text content
//                            VStack(alignment: .leading, spacing: 4) {
//                                Text("@\(comment.user.username)")
//                                    .font(.caption)
//                                    .foregroundStyle(.secondary)
//                                
//                                Text(comment.text)
//                                    .font(.body)
//                            }
//                            
//                            Spacer()
//                        }
//                    }
                }
                .padding(.horizontal)
            }
            
            Spacer()
            
            // MARK: - Comment Input Bar
            HStack(spacing: 10) {
                
                // Avatar
                AsyncImage(url: URL(string: UserStore.shared.profile?.avatarUrl ?? "")) { image in
                    image.resizable().scaledToFill()
                } placeholder: {
                    Color.gray.opacity(0.3)
                }
                .frame(width: 36, height: 36)
                .clipShape(Circle())
                
                // Input pill
                HStack {
                    TextField("Add a comment...", text: $commentText)
                        .padding(.horizontal, 6)
                }
                .padding(.vertical, 10)
                .padding(.horizontal, 12)
                .background(Color(.secondarySystemBackground))
                .clipShape(Capsule())
                
                // Send button
                Button {
                    Task { await submitComment() }
                } label: {
                    Image(systemName: "paperplane.fill")
                        .font(.system(size: 18))
                }
                .disabled(commentText.isEmpty)
            }
            .padding()
            .background(.ultraThinMaterial)
        }
        .presentationDetents([.medium, .large])
    }
    
    // MARK: - Submit Comment
    private func submitComment() async {
        guard !commentText.isEmpty else { return }
        
        // Get the current username from the session
        guard let username = try? await PawparazziAPI.shared.fetchProfile().user.username else {
            print("No logged-in user")
            return
        }
        
        await CatStore.shared.postComment(
            for: cat.id,
            comment: commentText
        )
        commentText = ""
    }
}
