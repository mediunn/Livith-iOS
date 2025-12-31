//
//  CommunityTabView.swift
//  ConcertFeature
//
//  Created by Youjin Lee on 12/30/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import SwiftUI

import ConcertDomain
import DSKit

struct CommunityTabView: View {

    // MARK: - Property

    @ObservedObject var store: CommunityStore

    // MARK: - Body

    var body: some View {
        VStack(spacing: 0) {
            contentArea
            CommentInputView(
                text: Binding(
                    get: { store.state.commentText },
                    set: { store.send(.updateCommentText($0)) }
                ),
                isSubmitting: store.state.isSubmitting,
                onSubmit: { store.send(.submitComment) }
            )
        }
        .livithToast(
            isPresented: Binding(
                get: { store.state.toastMessage != nil && store.state.toastType == .success },
                set: { _ in store.send(.onToastDismiss) }
            ),
            type: .success,
            message: store.state.toastMessage ?? ""
        )
        .livithToast(
            isPresented: Binding(
                get: { store.state.toastMessage != nil && store.state.toastType == .failure },
                set: { _ in store.send(.onToastDismiss) }
            ),
            type: .failure,
            message: store.state.toastMessage ?? ""
        )
    }
}

// MARK: - Content Area

private extension CommunityTabView {
    @ViewBuilder
    var contentArea: some View {
        if store.state.comments.isEmpty && !store.state.isLoading {
            emptyContent
        } else {
            commentList
        }
    }

    var emptyContent: some View {
        VStack(spacing: 20) {
            headerView

            LivithEmptyView(text: "첫 댓글을 달아보세요!")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .padding(.top, 30)
    }

    var commentList: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                headerView
                    .padding(.bottom, 8)

                ForEach(store.state.comments) { comment in
                    CommentCardView(
                        comment: comment,
                        onDelete: { store.send(.deleteComment(commentID: comment.id)) },
                        onReport: { store.send(.reportComment(commentID: comment.id)) }
                    )
                    .onAppear {
                        if comment.id == store.state.comments.last?.id {
                            store.send(.loadNextPage)
                        }
                    }
                }

                if store.state.isLoadingMore {
                    ProgressView()
                        .tint(Color.livithColor(.white100))
                        .padding()
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 30)
            .padding(.bottom, 20)
        }
    }
}

// MARK: - Header View

private extension CommunityTabView {
    var headerView: some View {
        HStack(spacing: 6) {
            Text("모든 댓글")
                .notosans(.body1Semibold)
                .foregroundStyle(Color.livithColor(.white100))

            Text("\(store.state.totalCount)")
                .notosans(.body1Semibold)
                .foregroundStyle(Color.livithColor(.yellow30))

            Spacer()
        }
    }
}

// MARK: - Preview

#Preview {
    CommunityTabView(store: CommunityStore())
        .background(Color.livithColor(.black100))
}
