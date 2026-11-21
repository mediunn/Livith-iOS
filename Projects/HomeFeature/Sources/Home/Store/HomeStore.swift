//
//  HomeStore.swift
//  HomeFeature
//
//  Created by 김진웅 on 12/29/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import Foundation
import SwiftUI

import DIContainer
import Domain
import LivithDesignSystem
import NicknameEditFeature

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
    case loadNickname
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
    @Injected private var userRepository: UserRepository

    private let sessionNickname: SessionNickname?
    private var isLoadingNickname = false

    private lazy var interestReducer = InterestHomeReducer(
        state: Binding(
            get: { [weak self] in self?.state.interest ?? InterestHomeState() },
            set: { [weak self] in self?.state.interest = $0 }
        ),
        send: { [weak self] in self?.send(.interest($0)) ?? .none }
    )
    private lazy var calendarReducer = CalendarHomeReducer(
        state: Binding(
            get: { [weak self] in self?.state.calendar ?? CalendarHomeState() },
            set: { [weak self] in self?.state.calendar = $0 }
        ),
        send: { [weak self] in self?.send(.calendar($0)) ?? .none }
    )

    private var cancellables = [CancelID: Task<Void, Never>]()

    init(sessionNickname: SessionNickname? = nil) {
        self.sessionNickname = sessionNickname
    }

    // MARK: - Public Interface

    var nickname: String? { sessionNickname?.nickname }

    @discardableResult
    func send(_ intent: HomeIntent) -> DiscardableTask {
        switch intent {
        case .homeAppear:
            performFetchUnreadCount()

        case .loadNickname:
            return performLoadNicknameIfNeeded() ?? .none

        case .homeTabSelected(let tab):
            state.selectedHomeTab = tab

        case .checkUnreadNotification:
            performFetchUnreadCount()

        case .interest(let interestIntent):
            let updateInterest = interestReducer.reduce(interestIntent)
            guard case .onRefresh = interestIntent,
                  let loadNickname = performLoadNicknameIfNeeded()
            else { return updateInterest }
            return DiscardableTask(task: Task {
                async let interest: Void = updateInterest.wait()
                async let nickname: Void = loadNickname.wait()
                _ = await (interest, nickname)
            })

        case .calendar(let calendarIntent):
            return calendarReducer.reduce(calendarIntent)

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
}

// MARK: - Shell Helpers

private extension HomeStore {
    func performLoadNicknameIfNeeded() -> DiscardableTask? {
        guard let sessionNickname, sessionNickname.nickname == nil, !isLoadingNickname else { return nil }
        isLoadingNickname = true

        return DiscardableTask(task: Task {
            defer { isLoadingNickname = false }
            guard !Task.isCancelled,
                  let nickname = try? await userRepository.refreshUser().nickname,
                  !Task.isCancelled,
                  sessionNickname.nickname == nil
            else { return }
            sessionNickname.nickname = nickname
        })
    }

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
