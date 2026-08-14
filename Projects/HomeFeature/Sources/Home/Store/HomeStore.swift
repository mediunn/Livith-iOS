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
    case _homeAppearResult(Result<(user: User, hasNewNotice: Bool), Error>)
    case _unreadCountResult(Result<Int, Error>)
}

// MARK: - Store

@MainActor
final class HomeStore: ObservableObject {

    enum CancelID {
        case homeAppear
        case unreadCount
        case interestAppear
        case interestList
        case sections
        case calendarFetchMonth
        case calendarFetchDayEvents
    }

    @Published private(set) var state: HomeState = .init()

    @Injected var userRepository: UserRepository
    @Injected var notificationRepository: NotificationRepository
    @Injected var concertRepository: ConcertRepository
    @Injected var calendarRepository: CalendarRepository

    var cancellables = [CancelID: Task<Void, Never>]()
    var pendingInterestResultAlertFetch = false
    var pendingInterestSectionList: [ConcertSection]?
    var isHomeAppearUserResolved = false
    var calendarMonthRequestID = 0
    var calendarDayEventsRequestID = 0

    // MARK: - Public Interface

    @discardableResult
    func send(_ intent: HomeIntent) -> DiscardableTask {
        switch intent {
        case .homeAppear:
            isHomeAppearUserResolved = false
            performHomeAppear()

        case .homeTabSelected(let tab):
            state.selectedHomeTab = tab

        case .checkUnreadNotification:
            performFetchUnreadCount()

        case .interest(let interestIntent):
            return withInterest { interest in
                reduceInterest(interestIntent, state: &interest)
            }

        case .calendar(let calendarIntent):
            return withCalendar { calendar in
                reduceCalendar(calendarIntent, state: &calendar)
            }

        case ._homeAppearResult(let result):
            switch result {
            case .success(let data):
                state.interest.user = data.user
                state.hasNewNotice = data.hasNewNotice
                isHomeAppearUserResolved = true
                flushPendingInterestSections()
            case .failure(let error):
                isHomeAppearUserResolved = true
                pendingInterestSectionList = nil
                _ = withInterest { interest in
                    applyHomeAppearFailure(from: error, state: &interest)
                    return .none
                }
            }

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
    func withInterest(
        _ body: (inout InterestHomeState) -> DiscardableTask
    ) -> DiscardableTask {
        var interest = state.interest
        let task = body(&interest)
        state.interest = interest
        return task
    }

    func withCalendar(
        _ body: (inout CalendarHomeState) -> DiscardableTask
    ) -> DiscardableTask {
        var calendar = state.calendar
        let task = body(&calendar)
        state.calendar = calendar
        return task
    }
}

// MARK: - Shell Helpers

extension HomeStore {
    func performHomeAppear() {
        cancellables[.homeAppear]?.cancel()

        cancellables[.homeAppear] = Task {
            async let userResult = fetchUser()
            async let hasNewNoticeResult = fetchHasNewNotice()

            let user = await userResult
            if Task.isCancelled { return }

            switch user {
            case .success(let user):
                send(._homeAppearResult(.success((
                    user: user,
                    hasNewNotice: hasNewNotice(from: await hasNewNoticeResult)
                ))))
            case .failure(let error):
                send(._homeAppearResult(.failure(error)))
            }
        }
    }

    func hasNewNotice(from result: Result<Bool, Error>) -> Bool {
        switch result {
        case .success(let hasNewNotice):
            return hasNewNotice
        case .failure:
            return false
        }
    }

    func fetchUser() async -> Result<User, Error> {
        do {
            return .success(try await userRepository.fetchUser())
        } catch {
            return .failure(error)
        }
    }

    func fetchHasNewNotice() async -> Result<Bool, Error> {
        do {
            let count = try await notificationRepository.fetchUnreadNotificationCount()
            return .success(count > 0)
        } catch {
            return .failure(error)
        }
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
