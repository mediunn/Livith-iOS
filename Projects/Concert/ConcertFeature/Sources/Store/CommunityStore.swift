//
//  CommunityStore.swift
//  ConcertFeature
//
//  Created by Youjin Lee on 12/31/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import Foundation

import ConcertDomain
import DIContainer
import LivithConcurrency

public struct CommunityState {
    public var concertID: Int = 0
    public var comments: [ConcertComment] = []
    public var totalCount: Int = 0
    public var commentText: String = ""
    public var isLoading: Bool = false
    public var isSubmitting: Bool = false
    public var isLoadingMore: Bool = false
    public var hasMorePages: Bool = true
    public var cursor: (createdAt: String, id: Int)? = nil
    public var toastMessage: String? = nil
    public var toastType: ToastType = .success

    public enum ToastType {
        case success
        case failure
    }

    public init() {}
}

public enum CommunityIntent {
    case onAppear(concertID: Int)
    case loadNextPage
    case submitComment
    case updateCommentText(String)
    case reportComment(commentID: Int)
    case onToastDismiss

    case _setComments([ConcertComment], totalCount: Int, cursor: (createdAt: String, id: Int)?)
    case _appendComments([ConcertComment], cursor: (createdAt: String, id: Int)?)
    case _addComment(ConcertComment)
    case _setLoading(Bool)
    case _setSubmitting(Bool)
    case _setLoadingMore(Bool)
    case _setHasMorePages(Bool)
    case _showToast(String, type: CommunityState.ToastType)
}

public final class CommunityStore: ObservableObject {

    // MARK: - Property

    private var fetchTask: Task<Void, Never>?
    private var loadMoreTask: Task<Void, Never>?
    @Published private(set) var state = CommunityState()

    @Injected private var repository: CommentRepository

    // MARK: - Initializer

    public init() {}

    // MARK: - Intent Handler

    @MainActor
    public func send(_ intent: CommunityIntent) {
        switch intent {
        case .onAppear(let concertID):
            state.concertID = concertID
            fetchComments()
        case .loadNextPage:
            loadNextPage()
        case .submitComment:
            submitComment()
        case .updateCommentText(let text):
            state.commentText = text
        case .reportComment(let commentID):
            reportComment(commentID: commentID)
        case .onToastDismiss:
            state.toastMessage = nil
        case ._setComments(let comments, let totalCount, let cursor):
            state.comments = comments
            state.totalCount = totalCount
            state.cursor = cursor
        case ._appendComments(let comments, let cursor):
            state.comments.append(contentsOf: comments)
            state.cursor = cursor
        case ._addComment(let comment):
            state.comments.insert(comment, at: 0)
            state.totalCount += 1
        case ._setLoading(let isLoading):
            state.isLoading = isLoading
        case ._setSubmitting(let isSubmitting):
            state.isSubmitting = isSubmitting
        case ._setLoadingMore(let isLoadingMore):
            state.isLoadingMore = isLoadingMore
        case ._setHasMorePages(let hasMorePages):
            state.hasMorePages = hasMorePages
        case ._showToast(let message, let type):
            state.toastMessage = message
            state.toastType = type
        }
    }
}

// MARK: - Private Methods

private extension CommunityStore {
    func fetchComments() {
        fetchTask?.cancel()

        fetchTask = Task { @MainActor in
            send(._setLoading(true))

            do {
                let result = try await repository.fetchConcertComments(
                    concertID: state.concertID,
                    cursor: nil,
                    size: 20
                )

                guard await Task.wait() else { return }

                send(._setComments(result.comments, totalCount: result.totalCount, cursor: result.cursor))
                send(._setHasMorePages(result.cursor != nil))
            } catch {
                guard !Task.isCancelled else { return }
                send(._showToast("댓글을 불러오는데 실패했어요", type: .failure))
            }

            send(._setLoading(false))
        }
    }

    func loadNextPage() {
        guard !state.isLoadingMore, state.hasMorePages, let cursor = state.cursor else { return }

        loadMoreTask?.cancel()

        loadMoreTask = Task { @MainActor in
            send(._setLoadingMore(true))

            do {
                let result = try await repository.fetchConcertComments(
                    concertID: state.concertID,
                    cursor: cursor,
                    size: 20
                )

                guard await Task.wait() else { return }

                send(._appendComments(result.comments, cursor: result.cursor))
                send(._setHasMorePages(result.cursor != nil))
            } catch {
                guard !Task.isCancelled else { return }
            }

            send(._setLoadingMore(false))
        }
    }

    func submitComment() {
        guard !state.commentText.isEmpty, !state.isSubmitting else { return }

        let content = state.commentText

        Task { @MainActor in
            send(._setSubmitting(true))

            do {
                let comment = try await repository.createComment(
                    concertID: state.concertID,
                    content: content
                )
                send(._addComment(comment))
                state.commentText = ""
                send(._showToast("댓글이 등록되었어요", type: .success))
            } catch {
                send(._showToast("댓글 등록에 실패했어요", type: .failure))
            }

            send(._setSubmitting(false))
        }
    }

    func reportComment(commentID: Int) {
        Task { @MainActor in
            do {
                try await repository.reportComment(commentID: commentID, content: nil)
                send(._showToast("신고가 접수되었어요", type: .success))
            } catch {
                send(._showToast("신고 접수에 실패했어요", type: .failure))
            }
        }
    }
}
