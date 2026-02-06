//
//  NotificationListStore.swift
//  UserFeature
//
//  Created by Youjin Lee on 2/6/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

import DIContainer
import Domain

// MARK: - State

struct NotificationListState {
    var notifications: [NotificationItem] = []
    var isLoading: Bool = false
    var isLoadingMore: Bool = false
    var hasMorePages: Bool = true
    var cursor: Int? = nil
}

// MARK: - Intent

enum NotificationListIntent {
    case onAppear
    case loadNextPage
    case _setNotifications([NotificationItem])
    case _appendNotifications([NotificationItem])
    case _setLoading(Bool)
    case _setLoadingMore(Bool)
    case _setHasMorePages(Bool)
    case _setCursor(Int?)
}

// MARK: - Store

final class NotificationListStore: ObservableObject {

    // MARK: - Constants

    private enum Constants {
        static let pageSize = 20
        static let loadingDelay: Duration = .milliseconds(300)
    }

    // MARK: - Property

    @Published private(set) var state = NotificationListState()

    private var fetchTask: Task<Void, Never>?
    private var loadMoreTask: Task<Void, Never>?

    @Injected private var userRepository: UserRepository

    // MARK: - Intent Handler

    @MainActor
    func send(_ intent: NotificationListIntent) {
        switch intent {
        case .onAppear:
            fetchNotifications()

        case .loadNextPage:
            loadNextPage()

        case ._setNotifications(let notifications):
            state.notifications = notifications

        case ._appendNotifications(let notifications):
            state.notifications.append(contentsOf: notifications)

        case ._setLoading(let isLoading):
            state.isLoading = isLoading

        case ._setLoadingMore(let isLoadingMore):
            state.isLoadingMore = isLoadingMore

        case ._setHasMorePages(let hasMorePages):
            state.hasMorePages = hasMorePages

        case ._setCursor(let cursor):
            state.cursor = cursor
        }
    }
}

// MARK: - Helper

private extension NotificationListStore {
    func fetchNotifications() {
        fetchTask?.cancel()

        fetchTask = Task { @MainActor in
            send(._setLoading(true))

            do {
                let notifications = try await userRepository.fetchNotificationList(
                    cursor: nil,
                    size: Constants.pageSize
                )

                guard !Task.isCancelled else { return }

                send(._setNotifications(notifications))
                send(._setHasMorePages(notifications.count >= Constants.pageSize))
                send(._setCursor(notifications.last?.id))
            } catch {
                guard !Task.isCancelled else { return }
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
                let notifications = try await userRepository.fetchNotificationList(
                    cursor: cursor,
                    size: Constants.pageSize
                )

                guard !Task.isCancelled else { return }

                send(._appendNotifications(notifications))
                send(._setHasMorePages(notifications.count >= Constants.pageSize))
                send(._setCursor(notifications.last?.id))
            } catch {
                guard !Task.isCancelled else { return }
            }

            send(._setLoadingMore(false))
        }
    }
}
