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
    var interestConcertList: [InterestConcert] = []
    var interestConcertSort: InterestConcertSort = .ticketing
    var errorMessage: String = ""
    var hasNewNotice: Bool = false
    var concertSectionList: [ConcertSection] = []
    var isSectionLoading: Bool = false
    var needsInitialSectionLoad: Bool = true
    var shouldShowPreferenceBanner: Bool = false
    var recommendedConcertList: [Concert] = []
    var shouldShowInterestResultSheet: Bool = false
    var interestResultAlertList: [InterestConcertEntryAlert] = []
}

// MARK: - Intent

enum HomeIntent {
    case homeAppear
    case interestAppear
    case onRefresh
    case homeTabSelected(SegmentedTabBarType.HomeTab)
    case onErrorToastDisappear
    case onInterestResultSheetDismiss
    case checkUnreadNotification
    case interestConcertSortSelected(InterestConcertSort)
    case _homeAppearResult(Result<(user: User, hasNewNotice: Bool), Error>)
    case _fetchUserResult(Result<User, Error>)
    case _interestListResult(Result<[InterestConcert], Error>)
    case _unreadCountResult(Result<Int, Error>)
    case _interestResultAlertListResult(Result<[InterestConcertEntryAlert], Error>)
    case _sectionLoadResult(Result<(sectionList: [ConcertSection], recommendedConcertList: [Concert]?), Error>)
}

// MARK: - Store

@MainActor
final class HomeStore: ObservableObject {
    private enum CancelID {
        case homeAppear
        case interestAppear
        case interestList
        case sections
        case unreadCount
    }

    /// `homeAppear`가 완료되기 전까지 `interestAppear`의 추천 조회가 대기하는 상태.
    private enum UserAvailability {
        case pending
        case available(User)
        case unavailable
    }

    private struct UserWaiter {
        let id: UUID
        let continuation: CheckedContinuation<User?, Never>
    }
    
    @Published private(set) var state: HomeState = .init()
    
    @Injected private var userRepository: UserRepository
    @Injected private var notificationRepository: NotificationRepository
    @Injected private var concertRepository: ConcertRepository
    
    private var cancellables = [CancelID: Task<Void, Never>]()
    private var pendingInterestResultAlertFetch = false
    private var userAvailability: UserAvailability = .pending
    private var userWaiters: [UserWaiter] = []

    // MARK: - Public Interface
    
    func send(_ intent: HomeIntent) {
        switch intent {
        case .homeAppear:
            userAvailability = .pending
            performHomeAppear()

        case .interestAppear:
            let loadsSections = state.needsInitialSectionLoad
            if loadsSections {
                state.isSectionLoading = true
                pendingInterestResultAlertFetch = true
            }
            performInterestAppear(loadsSections: loadsSections)

        case .onRefresh:
            performFetchSections()

        case .homeTabSelected(let tab):
            state.selectedHomeTab = tab

        case .onErrorToastDisappear:
            state.errorMessage = ""

        case .onInterestResultSheetDismiss:
            guard state.shouldShowInterestResultSheet else { return }
            clearInterestResultSheet()

        case .checkUnreadNotification:
            performFetchUnreadCount()

        case .interestConcertSortSelected(let sort):
            guard state.interestConcertSort != sort else { return }

            state.interestConcertSort = sort
            performFetchInterestList(filter: .homeSection(sort: sort))

        case ._homeAppearResult(let result):
            switch result {
            case .success(let data):
                state.user = data.user
                state.hasNewNotice = data.hasNewNotice
                resolveUserAvailability(with: data.user)
            case .failure(let error):
                pendingInterestResultAlertFetch = false
                state.isSectionLoading = false
                setError(from: error)
                resolveUserAvailability(with: nil)
            }

        case ._fetchUserResult(let result):
            switch result {
            case .success(let user):
                state.user = user
                guard state.needsInitialSectionLoad else { return }

                state.isSectionLoading = true
                state.needsInitialSectionLoad = false
                pendingInterestResultAlertFetch = true
                performFetchSections()
            case .failure(let error):
                setError(from: error)
            }

        case ._interestListResult(let result):
            switch result {
            case .success(let list):
                state.interestConcertList = list
                // 유저 조회 실패로 설정된 에러를 관심 목록 성공이 지우지 않도록,
                // 유저가 있을 때만(정렬 재조회 등) 에러를 클리어한다.
                if state.user != nil {
                    state.errorMessage = ""
                }
            case .failure(let error):
                setError(from: error)
            }

        case ._unreadCountResult(let result):
            switch result {
            case .success(let count):
                state.hasNewNotice = count > 0
            case .failure:
                state.hasNewNotice = false
            }

        case ._interestResultAlertListResult(let result):
            switch result {
            case .success(let alertList):
                guard shouldPresentInterestResultSheet(for: alertList) else {
                    clearInterestResultSheet()
                    return
                }
                guard state.errorMessage.isEmpty else {
                    clearInterestResultSheet()
                    return
                }

                state.interestResultAlertList = alertList
                state.shouldShowInterestResultSheet = true
            case .failure:
                clearInterestResultSheet()
            }

        case ._sectionLoadResult(let result):
            if case .failure(let error) = result, isCancellationError(error) {
                return
            }

            let isInitialLoad = pendingInterestResultAlertFetch
            state.isSectionLoading = false

            if isInitialLoad {
                state.needsInitialSectionLoad = false
                pendingInterestResultAlertFetch = false
            }

            switch result {
            case .success(let data):
                state.concertSectionList = data.sectionList
                state.shouldShowPreferenceBanner = !(state.user?.hasPreferences ?? false)
                state.recommendedConcertList = data.recommendedConcertList ?? []
                state.errorMessage = ""
                if isInitialLoad {
                    performFetchInterestResultAlertList()
                }
            case .failure(let error):
                setError(from: error)
            }
        }
    }
}

// MARK: - Helpers

private extension HomeStore {
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
                // 미대기 async let은 스코프 종료 시 취소된다.
                send(._homeAppearResult(.failure(error)))
            }
        }
    }

    func performInterestAppear(loadsSections: Bool) {
        cancellables[.interestAppear]?.cancel()

        let sort = state.interestConcertSort

        cancellables[.interestAppear] = Task {
            async let interestListResult = fetchInterestList(filter: .homeSection(sort: sort))
            async let sectionsResult = fetchSectionsIfNeeded(loadsSections)

            // 관심 목록 실패는 초기 로드 실패로 전파하지 않는다.
            send(._interestListResult(.success(interestList(from: await interestListResult))))

            guard loadsSections else { return }
            await sendSectionResult(sectionsResult: await sectionsResult)
        }
    }

    func interestList(from result: Result<[InterestConcert], Error>) -> [InterestConcert] {
        switch result {
        case .success(let list):
            return list
        case .failure:
            return []
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

    /// 섹션 조회 성공 시 유저 조회가 끝날 때까지 대기해 추천을 함께 반영한다.
    /// `homeAppear`의 유저 조회가 실패하면(`waitForUser`가 `nil` 반환) 섹션 결과를 UI에 반영하지 않는다.
    func sendSectionResult(sectionsResult: Result<[ConcertSection], Error>?) async {
        if Task.isCancelled { return }
        guard let sectionsResult else { return }

        switch sectionsResult {
        case .success(let sectionList):
            guard let user = await waitForUser() else { return }
            if Task.isCancelled { return }

            let recommendations = await fetchRecommendations(for: user)
            if Task.isCancelled { return }
            send(._sectionLoadResult(.success((
                sectionList: sectionList,
                recommendedConcertList: recommendations
            ))))
        case .failure(let error):
            if Task.isCancelled || isCancellationError(error) { return }
            send(._sectionLoadResult(.failure(error)))
        }
    }

    func fetchUser() async -> Result<User, Error> {
        do {
            return .success(try await userRepository.fetchUser())
        } catch {
            return .failure(error)
        }
    }

    func fetchInterestList(filter: InterestConcertListFilter) async -> Result<[InterestConcert], Error> {
        do {
            let response = try await userRepository.fetchInterestedConcertList(filter: filter)
            return .success(response.items)
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

    func fetchSectionsIfNeeded(_ shouldLoad: Bool) async -> Result<[ConcertSection], Error>? {
        guard shouldLoad else { return nil }
        return await fetchSections()
    }

    func fetchSections() async -> Result<[ConcertSection], Error> {
        do {
            let sections = try await concertRepository.fetchHomeConcertSectionList()
            return .success(sections)
        } catch {
            return .failure(error)
        }
    }

    func fetchInterestResultAlertList() async -> Result<[InterestConcertEntryAlert], Error> {
        do {
            return .success(try await userRepository.fetchInterestConcertEntryAlerts())
        } catch {
            return .failure(error)
        }
    }

    func performFetchInterestResultAlertList() {
        Task {
            let result = await fetchInterestResultAlertList()
            send(._interestResultAlertListResult(result))
        }
    }

    func performFetchInterestList(filter: InterestConcertListFilter) {
        cancellables[.interestList]?.cancel()
        cancellables[.interestList] = Task {
            let result = await fetchInterestList(filter: filter)
            send(._interestListResult(result))
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

    func performFetchSections() {
        cancellables[.sections]?.cancel()
        cancellables[.sections] = Task {
            do {
                async let sections = concertRepository.fetchHomeConcertSectionList()
                async let recommendations = fetchRecommendationsIfNeeded()
                
                let sectionList = try await sections
                if Task.isCancelled { return }
                let recommendedConcertList = await recommendations
                if Task.isCancelled { return }
                send(._sectionLoadResult(.success((
                    sectionList: sectionList,
                    recommendedConcertList: recommendedConcertList
                ))))
            } catch {
                if Task.isCancelled || isCancellationError(error) { return }
                send(._sectionLoadResult(.failure(error)))
            }
        }
    }

    func fetchRecommendationsIfNeeded() async -> [Concert]? {
        guard let user = state.user else { return nil }
        return await fetchRecommendations(for: user)
    }

    func fetchRecommendations(for user: User) async -> [Concert]? {
        guard user.hasPreferences else { return nil }

        do {
            return try await concertRepository.fetchRecommendedConcertList()
        } catch {
            return []
        }
    }
    
    func errorMessage(from error: Error) -> String {
        if isCancellationError(error) {
            return ""
        }
        
        return error.localizedDescription
    }

    func isCancellationError(_ error: Error) -> Bool {
        if error is CancellationError {
            return true
        }
        if case let error as ConcertError = error, error == .cancelled {
            return true
        }
        return false
    }

    func setError(from error: Error) {
        let message = errorMessage(from: error)
        state.errorMessage = message

        guard !message.isEmpty else { return }
        clearInterestResultSheet()
    }

    func clearInterestResultSheet() {
        state.shouldShowInterestResultSheet = false
        state.interestResultAlertList = []
    }

    func shouldPresentInterestResultSheet(for alertList: [InterestConcertEntryAlert]) -> Bool {
        !alertList.isEmpty
    }
}
