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
    case loadNextPage
    case _fetchNotificationListResult(Result<[NotificationItem], Error>)
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
            performFetchNotificationList()

        case .loadNextPage:
            guard !state.isLoadingMore, state.hasMorePages else { return }
            state.isLoadingMore = true
            performFetchNotificationList()

        case ._fetchNotificationListResult(let result):
            state.isLoading = false
            state.isLoadingMore = false

            switch result {
            case .success(let notifications):
                if notifications.isEmpty {
                    state.hasMorePages = false
                } else {
                    state.notifications.append(contentsOf: notifications)
                    state.cursor = notifications.last?.id
                    state.hasMorePages = notifications.count >= pageSize
                }
            case .failure:
                state.hasMorePages = false
            }
        }
    }
}

// MARK: - Helper

private extension NoticeStore {
    func performFetchNotificationList() {
        Task {
            do {
                let notifications = try await userRepository.fetchNotificationList(
                    cursor: state.cursor,
                    size: pageSize
                )
                await MainActor.run {
                    send(._fetchNotificationListResult(.success(notifications)))
                }
            } catch {
                await MainActor.run {
                    send(._fetchNotificationListResult(.failure(error)))
                }
            }
        }
    }
}
