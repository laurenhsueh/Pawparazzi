//
//  CommentsSheet.swift
//  Pawparazzi
//
//  Created by Lauren Hsueh on 12/11/25.
//


import SwiftUI

struct CommentsSheet: View {
    let cat: CatModel

    @StateObject private var store = CatStore.shared
    @State private var commentText = ""
    @FocusState private var isInputFocused: Bool

    private var comments: [CommentModel] {
        store.comments[cat.id] ?? cat.comments
    }

    private var hasMore: Bool {
        store.commentNextPage[cat.id] != nil
    }

    var body: some View {
        VStack(spacing: 0) {
            // Grabber bar (like Instagram)
            // Capsule()
            //     .fill(Color.gray.opacity(0.4))
            //     .frame(width: 40, height: 5)
            //     .padding(.top, 12)

            // Title
            Text("Comments")
                .font(.custom("AnticDidone-Regular", size: 24))
                .padding(.top, 8)
                .padding(.vertical, 16)

            Divider().padding(.vertical, 8)

            CommentsListSection(
                comments: comments,
                isLoading: store.isLoadingComments(for: cat.id),
                error: store.commentError(for: cat.id),
                hasMore: hasMore,
                onLoadMore: { Task { await store.loadMoreCommentsIfNeeded(for: cat.id) } },
                onRetry: { Task { await store.refreshComments(for: cat.id) } }
            )

            CommentInputBar(
                text: $commentText,
                isPosting: store.isPostingComment(for: cat.id),
                error: store.commentPostError(for: cat.id),
                isFocused: $isInputFocused,
                onSubmit: { Task { await submitComment() } }
            )
            .padding(.bottom, 8)
        }
        .background(AppColors.background)
        .presentationDetents([.medium, .large])
        .task {
            await loadInitialComments()
        }
    }

    private func loadInitialComments() async {
        if store.comments[cat.id] == nil {
            await store.loadComments(for: cat.id, reset: true)
        }
    }

    // MARK: - Submit Comment
    private func submitComment() async {
        let trimmed = commentText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        await store.postComment(
            for: cat.id,
            comment: trimmed
        )

        if store.commentPostError(for: cat.id) == nil {
            commentText = ""
            isInputFocused = false
        }
    }
}

// MARK: - Subviews
private struct CommentsListSection: View {
    let comments: [CommentModel]
    let isLoading: Bool
    let error: String?
    let hasMore: Bool
    let onLoadMore: () -> Void
    let onRetry: () -> Void

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 14) {
                if let error {
                    ErrorRow(message: error, onRetry: onRetry)
                }

                if isLoading && comments.isEmpty {
                    ProgressView()
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.vertical, 12)
                }

                ForEach(comments) { comment in
                    CommentRow(comment: comment)
                }

                if hasMore {
                    Button {
                        onLoadMore()
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "arrow.down.circle")
                            Text("Load more")
                        }
                        .font(.custom("Inter-Regular", size: 14))
                        .padding(.vertical, 8)
                        .frame(maxWidth: .infinity)
                    }
                    .disabled(isLoading)
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 12)
        }
    }
}

private struct CommentRow: View {
    let comment: CommentModel
    private let dateFormatter: RelativeDateTimeFormatter = {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return formatter
    }()

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            AvatarView(urlString: comment.user.avatarUrl)
                .frame(width: 36, height: 36)

            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 8) {
                    Text("@\(comment.user.username)")
                        .font(.custom("Inter-Regular", size: 13))
                        .foregroundStyle(AppColors.accent)

                    Text(dateFormatter.localizedString(for: comment.commentAt, relativeTo: Date()))
                        .font(.custom("Inter-Regular", size: 11))
                        .foregroundStyle(AppColors.mutedText)
                }

                Text(comment.comment)
                    .font(.custom("Inter-Regular", size: 14))
                    .foregroundStyle(.primary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer()
        }
    }
}

private struct AvatarView: View {
    let urlString: String?

    var body: some View {
        Group {
            if let urlString, let url = URL(string: urlString) {
                AsyncImage(url: url) { image in
                    image.resizable().scaledToFill()
                } placeholder: {
                    Color.gray.opacity(0.2)
                }
            } else {
                Color.gray.opacity(0.2)
                    .overlay {
                        Image(systemName: "person.fill")
                            .foregroundStyle(.white.opacity(0.7))
                    }
            }
        }
        .clipShape(Circle())
    }
}

private struct CommentInputBar: View {
    @Binding var text: String
    let isPosting: Bool
    let error: String?
    @FocusState.Binding var isFocused: Bool
    let onSubmit: () -> Void

    var body: some View {
        VStack(spacing: 8) {
            if let error, !error.isEmpty {
                Text(error)
                    .font(.custom("Inter-Regular", size: 12))
                    .foregroundStyle(.red)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 16)
            }

            HStack(spacing: 10) {
                AvatarView(urlString: UserStore.shared.profile?.avatarUrl)
                    .frame(width: 32, height: 32)

                TextField("Add a comment...", text: $text, axis: .vertical)
                    .textFieldStyle(.plain)
                    .font(.custom("Inter-Regular", size: 14))
                    .padding(.vertical, 8)
                    .padding(.horizontal, 10)
                    .focused($isFocused)
                    .background(AppColors.secondarySystemBackground)
                    .clipShape(Capsule())

                Button(action: onSubmit) {
                    if isPosting {
                        ProgressView()
                            .progressViewStyle(.circular)
                    } else {
                        Image(systemName: "paperplane.fill")
                    }
                }
                .disabled(text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isPosting)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(.ultraThinMaterial)
        }
    }
}

private struct ErrorRow: View {
    let message: String
    let onRetry: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Couldn't load comments")
                .font(.custom("Inter-Regular", size: 14))
            Text(message)
                .font(.custom("Inter-Regular", size: 12))
                .foregroundStyle(.red)
            Button("Retry", action: onRetry)
                .font(.custom("Inter-Regular", size: 12))
                .padding(.top, 4)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 8)
    }
}
