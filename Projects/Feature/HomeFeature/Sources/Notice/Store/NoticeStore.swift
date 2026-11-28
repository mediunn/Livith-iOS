//
//  NoticeStore.swift
//  HomeFeature
//
//  Created by Youjin Lee on 2/6/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

import DIContainer
import Domain

// MARK: - State

struct NoticeState {
    var notifications: [NotificationItem] = []
    var cursor: Int? = nil
    var hasMorePages: Bool = true
    var isLoading: Bool = false
    var isLoadingMore: Bool = false
    var isMarkingAllAsRead: Bool = false
}

// MARK: - Intent

enum NoticeIntent {
    case onAppear
    case refresh
    case loadNextPage
    case markAsRead(id: Int)
    case markAllAsRead
    case _fetchNotificationListResult(Result<[NotificationItem], Error>, isRefresh: Bool)
    case _markAllAsReadResult(Result<Void, Error>)
}

// MARK: - Store

final class NoticeStore: ObservableObject {
    @Published private(set) var state = NoticeState()

    @Injected private var notificationRepository: NotificationRepository

    private let pageSize = 20

    @MainActor
    func send(_ intent: NoticeIntent) {
        switch intent {
        case .onAppear:
            guard state.notifications.isEmpty else { return }
            state.isLoading = true
            performFetchNotificationList(isRefresh: false)

        case .refresh:
            state.cursor = nil
            state.hasMorePages = true
            state.isLoading = true
            performFetchNotificationList(isRefresh: true)

        case .loadNextPage:
            guard !state.isLoadingMore, state.hasMorePages else { return }
            state.isLoadingMore = true
            performFetchNotificationList(isRefresh: false)

        case .markAsRead(let id):
            performMarkNotificationAsRead(id: id)

        case .markAllAsRead:
            guard !state.isMarkingAllAsRead else { return }
            state.isMarkingAllAsRead = true
            performMarkAllNotificationsAsRead()

        case ._markAllAsReadResult(let result):
            state.isMarkingAllAsRead = false
            if case .success = result {
                state.notifications = state.notifications.map { notification in
                    NotificationItem(
                        id: notification.id,
                        type: notification.type,
                        title: notification.title,
                        content: notification.content,
                        targetID: notification.targetID,
                        isRead: true,
                        createdAt: notification.createdAt
                    )
                }
            }

        case ._fetchNotificationListResult(let result, let isRefresh):
            state.isLoading = false
            state.isLoadingMore = false

            switch result {
            case .success(let notifications):
                if isRefresh {
                    state.notifications = notifications
                } else {
                    state.notifications.append(contentsOf: notifications)
                }
                state.cursor = notifications.last?.id
                state.hasMorePages = notifications.count >= pageSize
            case .failure:
                state.hasMorePages = false
            }
        }
    }
}

// MARK: - Public Methods

extension NoticeStore {
    @MainActor
    func refreshAsync() async {
        state.cursor = nil
        state.hasMorePages = true

        do {
            let notifications = try await notificationRepository.fetchNotificationList(cursor: nil, size: pageSize)
            state.notifications = notifications
            state.cursor = notifications.last?.id
            state.hasMorePages = notifications.count >= pageSize
        } catch {
            // 실패 시 기존 목록 유지
        }
    }
}

// MARK: - Helper

private extension NoticeStore {
    func performFetchNotificationList(isRefresh: Bool) {
        Task {
            do {
                let notifications = try await notificationRepository.fetchNotificationList(
                    cursor: isRefresh ? nil : state.cursor,
                    size: pageSize
                )
                await MainActor.run {
                    send(._fetchNotificationListResult(.success(notifications), isRefresh: isRefresh))
                }
            } catch {
                await MainActor.run {
                    send(._fetchNotificationListResult(.failure(error), isRefresh: isRefresh))
                }
            }
        }
    }

    func performMarkNotificationAsRead(id: Int) {
        Task {
            try? await notificationRepository.markNotificationAsRead(id: id)
        }
    }

    func performMarkAllNotificationsAsRead() {
        Task {
            do {
                try await notificationRepository.markAllNotificationsAsRead()
                await MainActor.run {
                    send(._markAllAsReadResult(.success(())))
                }
            } catch {
                await MainActor.run {
                    send(._markAllAsReadResult(.failure(error)))
                }
            }
        }
    }
}
