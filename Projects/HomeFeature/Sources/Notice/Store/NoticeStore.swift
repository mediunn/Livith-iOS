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
}

// MARK: - Intent

enum NoticeIntent {
    case onAppear
    case refresh
    case loadNextPage
    case markAsRead(id: Int)
    case _fetchNotificationListResult(Result<[NotificationItem], Error>, isRefresh: Bool)
}

// MARK: - Store

final class NoticeStore: ObservableObject {
    @Published private(set) var state = NoticeState()

    @Injected private var userRepository: UserRepository

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
            guard let index = state.notifications.firstIndex(where: { $0.id == id }) else { return }
            state.notifications[index].isRead = true

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

// MARK: - Helper

private extension NoticeStore {
    func performFetchNotificationList(isRefresh: Bool) {
        Task {
            do {
                let notifications = try await userRepository.fetchNotificationList(
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
}
