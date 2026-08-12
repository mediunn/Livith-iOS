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
    var user: User? = nil
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
    case _fetchUserResult(Result<User, Error>)
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

    /// `homeAppear`가 완료되기 전까지 관심 탭 `onAppear`의 추천 조회가 대기하는 상태.
    enum UserAvailability {
        case pending
        case available(User)
        case unavailable
    }

    struct UserWaiter {
        let id: UUID
        let continuation: CheckedContinuation<User?, Never>
    }

    @Published private(set) var state: HomeState = .init()

    @Injected var userRepository: UserRepository
    @Injected var notificationRepository: NotificationRepository
    @Injected var concertRepository: ConcertRepository
    @Injected var calendarRepository: CalendarRepository

    var cancellables = [CancelID: Task<Void, Never>]()
    var userAvailability: UserAvailability = .pending
    var userWaiters: [UserWaiter] = []
    var pendingInterestResultAlertFetch = false
    var calendarMonthRequestID = 0
    var calendarDayEventsRequestID = 0

    // MARK: - Public Interface

    @discardableResult
    func send(_ intent: HomeIntent) -> DiscardableTask {
        switch intent {
        case .homeAppear:
            userAvailability = .pending
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
                state.user = data.user
                state.hasNewNotice = data.hasNewNotice
                resolveUserAvailability(with: data.user)
            case .failure(let error):
                _ = withInterest { interest in
                    applyHomeAppearFailure(from: error, state: &interest)
                    return .none
                }
                resolveUserAvailability(with: nil)
            }

        case ._fetchUserResult(let result):
            switch result {
            case .success(let user):
                state.user = user
                guard state.interest.needsInitialSectionLoad else { return .none }
                _ = withInterest { interest in
                    beginInitialSectionLoad(state: &interest, user: user)
                    return .none
                }
            case .failure(let error):
                _ = withInterest { interest in
                    applyInterestError(from: error, state: &interest)
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

    /// `homeAppear`의 유저 조회 결과를 대기한다. 이미 결과가 나와 있으면 즉시 반환하고,
    /// 아직 진행 중이면 `resolveUserAvailability`가 호출될 때까지 대기한다.
    /// 유저 조회가 실패하거나 대기 중 Task가 취소되면 `nil`을 반환해 추천 조회를 건너뛴다.
    func waitForUser() async -> User? {
        switch userAvailability {
        case .available(let user):
            return user
        case .unavailable:
            return nil
        case .pending:
            let waiterID = UUID()
            return await withTaskCancellationHandler {
                await withCheckedContinuation { continuation in
                    if Task.isCancelled {
                        continuation.resume(returning: nil)
                        return
                    }
                    userWaiters.append(UserWaiter(id: waiterID, continuation: continuation))
                }
            } onCancel: {
                Task { @MainActor in
                    resumeUserWaiter(id: waiterID, returning: nil)
                }
            }
        }
    }

    func resolveUserAvailability(with user: User?) {
        userAvailability = user.map { .available($0) } ?? .unavailable

        let waiters = userWaiters
        userWaiters.removeAll()
        waiters.forEach { $0.continuation.resume(returning: user) }
    }

    func resumeUserWaiter(id: UUID, returning user: User?) {
        guard let index = userWaiters.firstIndex(where: { $0.id == id }) else { return }
        let waiter = userWaiters.remove(at: index)
        waiter.continuation.resume(returning: user)
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
