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
    public var toastState: ToastState = .none
    public var dialogState: DialogState = .none

    public enum ToastState: Equatable {
        case none
        case success(String)
        case failure(String)
    }

    public enum DialogState: Equatable {
        case none
        case delete(commentID: Int)
        case report(commentID: Int)
    }

    public init() {}
}

public enum CommunityIntent {
    case onAppear(concertID: Int)
    case loadNextPage
    case submitComment
    case updateCommentText(String)

    case showDeleteDialog(commentID: Int)
    case showReportDialog(commentID: Int)
    case confirmDelete
    case confirmReport(content: String)
    case dismissDialog

    case dismissToast

    case _setComments([ConcertComment], totalCount: Int, cursor: (createdAt: String, id: Int)?)
    case _appendComments([ConcertComment], cursor: (createdAt: String, id: Int)?)
    case _addComment(ConcertComment)
    case _removeComment(commentID: Int)
    case _setCommentText(String)
    case _setLoading(Bool)
    case _setSubmitting(Bool)
    case _setLoadingMore(Bool)
    case _setHasMorePages(Bool)
    case _setToast(CommunityState.ToastState)
}

public final class CommunityStore: ObservableObject {

    // MARK: - Constants

    private enum Constants {
        static let pageSize = 15
        static let loadingDelay: Duration = .milliseconds(500)
        static let fetchErrorMessage = "댓글을 불러오는 데 실패했어요"
        static let submitSuccessMessage = "댓글이 작성되었어요"
        static let submitErrorMessage = "댓글 작성에 실패했어요"
        static let deleteSuccessMessage = "댓글이 삭제되었어요"
        static let deleteErrorMessage = "댓글 삭제에 실패했어요"
        static let reportSuccessMessage = "신고가 완료되었어요\n검토 후 처리까지 약 1-2일 소요될 수 있어요"
        static let reportErrorMessage = "신고 접수에 실패했어요"
    }

    // MARK: - Property

    private var fetchTask: Task<Void, Never>?
    private var loadMoreTask: Task<Void, Never>?
    private var submitTask: Task<Void, Never>?
    private var deleteTask: Task<Void, Never>?
    private var reportTask: Task<Void, Never>?
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
        case .showDeleteDialog(let commentID):
            state.dialogState = .delete(commentID: commentID)
        case .showReportDialog(let commentID):
            state.dialogState = .report(commentID: commentID)
        case .confirmDelete:
            if case .delete(let commentID) = state.dialogState {
                state.dialogState = .none
                deleteComment(commentID: commentID)
            }
        case .confirmReport(let content):
            if case .report(let commentID) = state.dialogState {
                state.dialogState = .none
                reportComment(commentID: commentID, content: content)
            }
        case .dismissDialog:
            state.dialogState = .none
        case .dismissToast:
            state.toastState = .none
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
        case ._removeComment(let commentID):
            state.comments.removeAll { $0.id == commentID }
            state.totalCount -= 1
        case ._setCommentText(let text):
            state.commentText = text
        case ._setLoading(let isLoading):
            state.isLoading = isLoading
        case ._setSubmitting(let isSubmitting):
            state.isSubmitting = isSubmitting
        case ._setLoadingMore(let isLoadingMore):
            state.isLoadingMore = isLoadingMore
        case ._setHasMorePages(let hasMorePages):
            state.hasMorePages = hasMorePages
        case ._setToast(let toastState):
            state.toastState = toastState
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
                    size: Constants.pageSize
                )

                guard await Task.wait() else { return }

                send(._setComments(result.comments, totalCount: result.totalCount, cursor: result.cursor))
                send(._setHasMorePages(result.cursor != nil))
            } catch {
                guard !Task.isCancelled else { return }
                send(._setToast(.failure(Constants.fetchErrorMessage)))
            }

            send(._setLoading(false))
        }
    }

    func loadNextPage() {
        guard !state.isLoading, !state.isLoadingMore, state.hasMorePages, let cursor = state.cursor else { return }

        loadMoreTask?.cancel()
        state.isLoadingMore = true

        loadMoreTask = Task { @MainActor in
            try? await Task.sleep(for: Constants.loadingDelay)
            guard !Task.isCancelled else {
                state.isLoadingMore = false
                return
            }

            do {
                let result = try await repository.fetchConcertComments(
                    concertID: state.concertID,
                    cursor: cursor,
                    size: Constants.pageSize
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

        submitTask?.cancel()

        let content = state.commentText

        submitTask = Task { @MainActor in
            send(._setSubmitting(true))

            do {
                let comment = try await repository.createComment(
                    concertID: state.concertID,
                    content: content
                )
                guard !Task.isCancelled else { return }
                send(._addComment(comment))
                send(._setCommentText(""))
                send(._setSubmitting(false))
                send(._setToast(.success(Constants.submitSuccessMessage)))
            } catch {
                guard !Task.isCancelled else { return }
                send(._setSubmitting(false))
                send(._setToast(.failure(Constants.submitErrorMessage)))
            }
        }
    }

    func deleteComment(commentID: Int) {
        deleteTask?.cancel()

        deleteTask = Task { @MainActor in
            do {
                try await repository.deleteComment(commentID: commentID)
                guard !Task.isCancelled else { return }
                send(._removeComment(commentID: commentID))
                send(._setToast(.success(Constants.deleteSuccessMessage)))
            } catch {
                guard !Task.isCancelled else { return }
                send(._setToast(.failure(Constants.deleteErrorMessage)))
            }
        }
    }

    func reportComment(commentID: Int, content: String) {
        reportTask?.cancel()

        reportTask = Task { @MainActor in
            do {
                try await repository.reportComment(commentID: commentID, content: content)
                guard !Task.isCancelled else { return }
                send(._setToast(.success(Constants.reportSuccessMessage)))
            } catch {
                guard !Task.isCancelled else { return }
                send(._setToast(.failure(Constants.reportErrorMessage)))
            }
        }
    }
}
