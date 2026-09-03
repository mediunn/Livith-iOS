//
//  HomeStore.swift
//  HomeFeature
//
//  Created by 김진웅 on 12/29/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import Foundation

import DIContainer
import Domain
import LivithDesignSystem

// MARK: - State

struct HomeState {
    var selectedHomeTab: SegmentedTabBarType.HomeTab = .interestConcert
    var hasNewNotice: Bool = false
    var interest: InterestHomeState = .init()
    var calendar: CalendarHomeState = .init()
}

// MARK: - Intent

enum HomeIntent {
    case homeAppear
    case homeTabSelected(SegmentedTabBarType.HomeTab)
    case checkUnreadNotification
    case interest(InterestHomeIntent)
    case calendar(CalendarHomeIntent)
    case _unreadCountResult(Result<Int, Error>)
}

// MARK: - Store

@MainActor
final class HomeStore: ObservableObject {

    private enum CancelID {
        case unreadCount
    }

    @Published private(set) var state: HomeState = .init()

    @Injected private var notificationRepository: NotificationRepository

    private lazy var interestReducer = InterestHomeReducer { [weak self] in
        self?.send(.interest($0)) ?? .none
    }
    private lazy var calendarReducer = CalendarHomeReducer { [weak self] in
        self?.send(.calendar($0)) ?? .none
    }

    private var cancellables = [CancelID: Task<Void, Never>]()

    // MARK: - Public Interface

    @discardableResult
    func send(_ intent: HomeIntent) -> DiscardableTask {
        switch intent {
        case .homeAppear:
            performFetchUnreadCount()

        case .homeTabSelected(let tab):
            state.selectedHomeTab = tab

        case .checkUnreadNotification:
            performFetchUnreadCount()

        case .interest(let interestIntent):
            return reduce(\.interest) { interestReducer.reduce(interestIntent, state: &$0) }

        case .calendar(let calendarIntent):
            return reduce(\.calendar) { calendarReducer.reduce(calendarIntent, state: &$0) }

        case ._unreadCountResult(let result):
            switch result {
            case .success(let count):
                state.hasNewNotice = count > 0
            case .failure:
                state.hasNewNotice = false
            }
        }

        return .none
    }
}

// MARK: - Child State

extension HomeStore {
    func scope<ChildState, ChildIntent>(
        _ keyPath: KeyPath<HomeState, ChildState>,
        intent: @escaping (ChildIntent) -> HomeIntent
    ) -> HomeScope<ChildState, ChildIntent> {
        HomeScope(
            state: state[keyPath: keyPath],
            send: { [self] in send(intent($0)) }
        )
    }

    func reduce<S>(
        _ keyPath: WritableKeyPath<HomeState, S>,
        _ body: (inout S) -> DiscardableTask
    ) -> DiscardableTask {
        var child = state[keyPath: keyPath]
        let task = body(&child)
        state[keyPath: keyPath] = child
        return task
    }
}

// MARK: - Shell Helpers

extension HomeStore {
    func performFetchUnreadCount() {
        cancellables[.unreadCount]?.cancel()
        cancellables[.unreadCount] = Task {
            do {
                let count = try await notificationRepository.fetchUnreadNotificationCount()
                send(._unreadCountResult(.success(count)))
            } catch {
                send(._unreadCountResult(.failure(error)))
            }
        }
    }
}
