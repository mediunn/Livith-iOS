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
    var interestToastMessage: String = ""
}

// MARK: - Intent

enum HomeIntent {
    case onAppear
    case onRefresh
    case homeTabSelected(SegmentedTabBarType.HomeTab)
    case onErrorToastDisappear
    case onInterestToastDisappear
    case checkUnreadNotification
    case interestConcertSortSelected(InterestConcertSort)
    case _initialLoadResult(Result<(user: User, interestConcertList: [InterestConcert], hasNewNotice: Bool), Error>)
    case _fetchUserResult(Result<User, Error>)
    case _interestListResult(Result<[InterestConcert], Error>)
    case _unreadCountResult(Result<Int, Error>)
    case _interestToastResult(Result<InterestConcertCleanupPolicy, Error>)
    case _markInterestToastResult(Result<Void, Error>)
    case _sectionLoadResult(Result<(sectionList: [ConcertSection], recommendedConcertList: [Concert]?), Error>)
}

// MARK: - Store

@MainActor
final class HomeStore: ObservableObject {
    private enum CancelID {
        case initialLoad
        case interestList
        case sections
        case unreadCount
    }
    
    @Published private(set) var state: HomeState = .init()
    
    @Injected private var userRepository: UserRepository
    @Injected private var notificationRepository: NotificationRepository
    @Injected private var concertRepository: ConcertRepository
    
    private var cancellables = [CancelID: Task<Void, Never>]()
    private var pendingInterestToast = false

    // MARK: - Public Interface
    
    func send(_ intent: HomeIntent) {
        switch intent {
        case .onAppear:
            let loadsSections = state.needsInitialSectionLoad
            if loadsSections {
                state.isSectionLoading = true
                pendingInterestToast = true
            }
            performInitialLoad(loadsSections: loadsSections)

        case .onRefresh:
            performFetchSections()

        case .homeTabSelected(let tab):
            state.selectedHomeTab = tab

        case .onErrorToastDisappear:
            state.errorMessage = ""

        case .onInterestToastDisappear:
            state.interestToastMessage = ""

        case .checkUnreadNotification:
            performFetchUnreadCount()

        case .interestConcertSortSelected(let sort):
            guard state.interestConcertSort != sort else { return }

            state.interestConcertSort = sort
            performFetchInterestList(filter: .homeSection(sort: sort))

        case ._initialLoadResult(let result):
            switch result {
            case .success(let data):
                state.user = data.user
                state.interestConcertList = data.interestConcertList
                state.hasNewNotice = data.hasNewNotice
            case .failure(let error):
                pendingInterestToast = false
                state.isSectionLoading = false
                setError(from: error)
            }

        case ._fetchUserResult(let result):
            switch result {
            case .success(let user):
                state.user = user
                guard state.needsInitialSectionLoad else { return }

                state.isSectionLoading = true
                state.needsInitialSectionLoad = false
                pendingInterestToast = true
                performFetchSections()
            case .failure(let error):
                setError(from: error)
            }

        case ._interestListResult(let result):
            switch result {
            case .success(let list):
                state.interestConcertList = list
                state.errorMessage = ""
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

        case ._interestToastResult(let result):
            switch result {
            case .success(let policy):
                guard let message = toastMessage(for: policy) else {
                    state.interestToastMessage = ""
                    return
                }
                guard state.errorMessage.isEmpty else {
                    state.interestToastMessage = ""
                    return
                }

                state.interestToastMessage = message
                performMarkInterestToastShown()
            case .failure:
                state.interestToastMessage = ""
            }

        case ._markInterestToastResult:
            break

        case ._sectionLoadResult(let result):
            let isInitialLoad = pendingInterestToast
            state.isSectionLoading = false

            if isInitialLoad {
                state.needsInitialSectionLoad = false
                pendingInterestToast = false
            }

            switch result {
            case .success(let data):
                state.concertSectionList = data.sectionList
                state.shouldShowPreferenceBanner = !(state.user?.hasPreferences ?? false)
                state.recommendedConcertList = data.recommendedConcertList ?? []
                state.errorMessage = ""
                if isInitialLoad {
                    performFetchInterestToast()
                }
            case .failure(let error):
                setError(from: error)
            }
        }
    }
}

// MARK: - Helpers

private extension HomeStore {
    func performInitialLoad(loadsSections: Bool) {
        cancellables[.initialLoad]?.cancel()

        let sort = state.interestConcertSort

        cancellables[.initialLoad] = Task {
            async let userResult = fetchUser()
            async let interestListResult = fetchInterestList(filter: .homeSection(sort: sort))
            async let hasNewNoticeResult = fetchHasNewNotice()
            async let sectionsResult = fetchSectionsIfNeeded(loadsSections)

            guard let user = resolveUser(from: await userResult) else { return }
            if Task.isCancelled { return }

            send(._initialLoadResult(.success((
                user: user,
                interestConcertList: interestList(from: await interestListResult),
                hasNewNotice: hasNewNotice(from: await hasNewNoticeResult)
            ))))

            guard loadsSections else { return }
            await sendSectionResult(user: user, sectionsResult: await sectionsResult)
        }
    }

    func resolveUser(from result: Result<User, Error>) -> User? {
        if Task.isCancelled { return nil }

        switch result {
        case .failure(let error):
            // 미대기 async let은 스코프 종료 시 취소된다.
            send(._initialLoadResult(.failure(error)))
            return nil
        case .success(let user):
            return user
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

    func hasNewNotice(from result: Result<Bool, Error>) -> Bool {
        switch result {
        case .success(let hasNewNotice):
            return hasNewNotice
        case .failure:
            return false
        }
    }

    func sendSectionResult(
        user: User,
        sectionsResult: Result<[ConcertSection], Error>?
    ) async {
        if Task.isCancelled { return }
        guard let sectionsResult else { return }

        switch sectionsResult {
        case .success(let sectionList):
            let recommendations = await fetchRecommendations(for: user)
            if Task.isCancelled { return }
            send(._sectionLoadResult(.success((
                sectionList: sectionList,
                recommendedConcertList: recommendations
            ))))
        case .failure(let error):
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

    func fetchInterestToast() async -> Result<InterestConcertCleanupPolicy, Error> {
        do {
            return .success(try await userRepository.fetchInterestConcertCleanupPolicy())
        } catch {
            return .failure(error)
        }
    }

    func performFetchInterestToast() {
        Task {
            let result = await fetchInterestToast()
            send(._interestToastResult(result))
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

    func performMarkInterestToastShown() {
        Task {
            do {
                try await userRepository.markInterestConcertToastShown()
                send(._markInterestToastResult(.success(())))
            } catch {
                send(._markInterestToastResult(.failure(error)))
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
                let recommendedConcertList = await recommendations
                send(._sectionLoadResult(.success((
                    sectionList: sectionList,
                    recommendedConcertList: recommendedConcertList
                ))))
            } catch {
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
        if error is CancellationError {
            return ""
        }
        
        if case let error as ConcertError = error, error == .cancelled {
            return ""
        }
        
        return error.localizedDescription
    }

    func setError(from error: Error) {
        let message = errorMessage(from: error)
        state.errorMessage = message

        guard !message.isEmpty else { return }
        state.interestToastMessage = ""
    }

    func toastMessage(for policy: InterestConcertCleanupPolicy) -> String? {
        switch policy {
        case .none:
            return nil
        case .canceled:
            return Constants.canceledToastMessage
        case .completed:
            return Constants.completedToastMessage
        case .both:
            return Constants.bothToastMessage
        }
    }

    enum Constants {
        static let canceledToastMessage = "취소된 공연이 자동 정리됐어요"
        static let completedToastMessage = "종료된 공연이 자동 정리됐어요"
        static let bothToastMessage = "종료·취소된 공연이 자동 정리됐어요"
    }
}
