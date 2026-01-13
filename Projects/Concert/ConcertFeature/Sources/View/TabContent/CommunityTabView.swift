//
//  CommunityTabView.swift
//  ConcertFeature
//
//  Created by Youjin Lee on 12/30/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import SwiftUI

import ConcertDomain
import LivithDesignSystem

struct CommunityTabView: View {

    // MARK: - Property

    @ObservedObject var store: CommunityStore

    // MARK: - Body

    var body: some View {
        contentArea
            .onTapGesture {
                hideKeyboard()
            }
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
        Group {
            headerView
                .padding(.horizontal, 16)
                .padding(.top, 30)
                .padding(.bottom, 20)

            LivithEmptyView(text: "첫 댓글을 달아보세요!")
                .frame(maxWidth: .infinity)
                .frame(height: 200)
        }
    }

    var commentList: some View {
        Group {
            headerView
                .padding(.horizontal, 16)
                .padding(.top, 30)
                .padding(.bottom, 20)

            ForEach(store.state.comments) { comment in
                CommentCardView(
                    comment: comment,
                    onDelete: { store.send(.showDeleteDialog(commentID: comment.id)) },
                    onReport: { store.send(.showReportDialog(commentID: comment.id)) }
                )
                .padding(.horizontal, 16)
                .padding(.bottom, 12)
                .onAppear {
                    if comment.id == store.state.comments.last?.id, store.state.hasMorePages {
                        store.send(.loadNextPage)
                    }
                }
            }

            if store.state.isLoadingMore, store.state.hasMorePages {
                ProgressView()
                    .tint(Color.livithColor(.white100))
                    .padding()
                    .frame(maxWidth: .infinity)
            }
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

// MARK: - Keyboard

private extension CommunityTabView {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

// MARK: - Preview

#Preview {
    ScrollView {
        CommunityTabView(store: CommunityStore())
    }
    .background(Color.livithColor(.black100))
}
