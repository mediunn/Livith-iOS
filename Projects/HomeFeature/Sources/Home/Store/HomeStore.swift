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

// MARK: - State

struct HomeState {
    var user: User? = nil
    var interestConcertList: [InterestConcert] = []
    var interestConcertSort: InterestConcertSort = .ticketing
    var errorMessage: String = ""
    var hasNewNotice: Bool = false
    var concertSectionList: [ConcertSection] = []
    var isConcertSectionLoading: Bool = false
    var isConcertSectionInitialLoad: Bool = true
    var shouldShowPreferenceBanner: Bool = false
    var recommendedConcertList: [Concert] = []
    var interestConcertToastMessage: String = ""
}

// MARK: - Intent

enum HomeIntent {
    case onAppear
    case onRefresh
    case onErrorToastDisappear
    case onInterestConcertToastDisappear
    case checkUnreadNotification
    case interestConcertSortSelected(InterestConcertSort)
    case _fetchInitialHomeDataResult(Result<(user: User, interestConcertList: [InterestConcert], hasNewNotice: Bool), Error>)
    case _fetchUserResult(Result<User, Error>)
    case _fetchInterestConcertListResult(Result<[InterestConcert], Error>)
    case _fetchUnreadNotificationCountResult(Result<Int, Error>)
    case _fetchInterestConcertToastResult(Result<Bool, Error>)
    case _markInterestConcertToastShownResult(Result<Void, Error>)
    case _fetchConcertSectionDataResult(Result<(sectionList: [ConcertSection], recommendedConcertList: [Concert]?), Error>)
}

// MARK: - Store

@MainActor
final class HomeStore: ObservableObject {
    private enum CancelID {
        case fetchInitialHomeData
        case fetchInterestConcertList
        case refreshSections
        case fetchUnreadNotificationCount
    }
    
    @Published private(set) var state: HomeState = .init()
    
    @Injected private var userRepository: UserRepository
    @Injected private var notificationRepository: NotificationRepository
    @Injected private var concertRepository: ConcertRepository
    
    private var cancellables = [CancelID: Task<Void, Never>]()
    private var shouldFetchInterestConcertToastAfterSectionLoad = false

    // MARK: - Public Interface
    
    func send(_ intent: HomeIntent) {
        switch intent {
        case .onAppear:
            performFetchInitialHomeData()

        case .onRefresh:
            performFetchConcertSectionData()

        case .onErrorToastDisappear:
            state.errorMessage = ""

        case .onInterestConcertToastDisappear:
            state.interestConcertToastMessage = ""

        case .checkUnreadNotification:
            performFetchUnreadNotificationCount()

        case .interestConcertSortSelected(let sort):
            guard state.interestConcertSort != sort else { return }

            state.interestConcertSort = sort
            performFetchInterestConcertList(filter: .homeSection(sort: sort))

        case ._fetchInitialHomeDataResult(let result):
            switch result {
            case .success(let data):
                state.user = data.user
                state.interestConcertList = data.interestConcertList
                state.hasNewNotice = data.hasNewNotice
                executeInitialConcertSectionLoadIfNeeded()
            case .failure(let error):
                setErrorMessage(from: error)
            }

        case ._fetchUserResult(let result):
            switch result {
            case .success(let user):
                state.user = user
                executeInitialConcertSectionLoadIfNeeded()
            case .failure(let error):
                setErrorMessage(from: error)
            }

        case ._fetchInterestConcertListResult(let result):
            switch result {
            case .success(let list):
                state.interestConcertList = list
                state.errorMessage = ""
            case .failure(let error):
                setErrorMessage(from: error)
            }

        case ._fetchUnreadNotificationCountResult(let result):
            switch result {
            case .success(let count):
                state.hasNewNotice = count > 0
            case .failure:
                state.hasNewNotice = false
            }

        case ._fetchInterestConcertToastResult(let result):
            switch result {
            case .success(true):
                guard state.errorMessage.isEmpty else {
                    state.interestConcertToastMessage = ""
                    return
                }

                state.interestConcertToastMessage = Constants.interestConcertToastMessage
                performMarkInterestConcertToastShown()
            case .success(false), .failure:
                state.interestConcertToastMessage = ""
            }

        case ._markInterestConcertToastShownResult:
            break

        case ._fetchConcertSectionDataResult(let result):
            state.isConcertSectionLoading = false

            switch result {
            case .success(let data):
                state.concertSectionList = data.sectionList
                state.shouldShowPreferenceBanner = !(state.user?.hasPreferences ?? false)
                state.recommendedConcertList = data.recommendedConcertList ?? []
                state.errorMessage = ""
                performFetchInterestConcertToastAfterSectionLoadIfNeeded()
            case .failure(let error):
                shouldFetchInterestConcertToastAfterSectionLoad = false
                setErrorMessage(from: error)
            }
        }
    }
}

// MARK: - Helpers

private extension HomeStore {
    func executeInitialConcertSectionLoadIfNeeded() {
        guard state.user != nil else { return }
        guard state.isConcertSectionInitialLoad else { return }

        state.isConcertSectionLoading = true
        state.isConcertSectionInitialLoad = false
        shouldFetchInterestConcertToastAfterSectionLoad = true
        performFetchConcertSectionData()
    }

    func performFetchInitialHomeData() {
        cancellables[.fetchInitialHomeData]?.cancel()
        cancellables[.fetchInitialHomeData] = Task {
            async let userResult = fetchUserResult()
            async let interestConcertListResult = fetchInterestConcertListResult(
                filter: .homeSection(sort: state.interestConcertSort)
            )
            async let hasNewNoticeResult = fetchHasNewNoticeResult()

            let (
                resolvedUserResult,
                resolvedInterestConcertListResult,
                resolvedHasNewNoticeResult
            ) = await (
                userResult,
                interestConcertListResult,
                hasNewNoticeResult
            )

            switch resolvedUserResult {
            case .success(let user):
                let list: [InterestConcert]
                switch resolvedInterestConcertListResult {
                case .success(let interestConcertList):
                    list = interestConcertList
                case .failure:
                    list = []
                }

                let hasNewNotice: Bool
                switch resolvedHasNewNoticeResult {
                case .success(let result):
                    hasNewNotice = result
                case .failure:
                    hasNewNotice = false
                }

                send(._fetchInitialHomeDataResult(.success((
                    user: user,
                    interestConcertList: list,
                    hasNewNotice: hasNewNotice
                ))))
            case .failure(let error):
                send(._fetchInitialHomeDataResult(.failure(error)))
            }
        }
    }

    func fetchUserResult() async -> Result<User, Error> {
        do {
            return .success(try await userRepository.fetchUser())
        } catch {
            return .failure(error)
        }
    }

    func fetchInterestConcertListResult(filter: InterestConcertListFilter) async -> Result<[InterestConcert], Error> {
        do {
            let response = try await userRepository.fetchInterestedConcertList(filter: filter)
            return .success(response.items)
        } catch {
            return .failure(error)
        }
    }

    func fetchHasNewNoticeResult() async -> Result<Bool, Error> {
        do {
            let count = try await notificationRepository.fetchUnreadNotificationCount()
            return .success(count > 0)
        } catch {
            return .failure(error)
        }
    }

    func fetchInterestConcertToastResult() async -> Result<Bool, Error> {
        do {
            return .success(try await userRepository.fetchInterestConcertToastNeedsToShow())
        } catch {
            return .failure(error)
        }
    }

    func performFetchInterestConcertToastAfterSectionLoadIfNeeded() {
        guard shouldFetchInterestConcertToastAfterSectionLoad else { return }

        shouldFetchInterestConcertToastAfterSectionLoad = false
        Task {
            let result = await fetchInterestConcertToastResult()
            send(._fetchInterestConcertToastResult(result))
        }
    }

    func performFetchInterestConcertList(filter: InterestConcertListFilter) {
        cancellables[.fetchInterestConcertList]?.cancel()
        cancellables[.fetchInterestConcertList] = Task {
            let result = await fetchInterestConcertListResult(filter: filter)
            send(._fetchInterestConcertListResult(result))
        }
    }

    func performFetchUnreadNotificationCount() {
        cancellables[.fetchUnreadNotificationCount]?.cancel()
        cancellables[.fetchUnreadNotificationCount] = Task {
            do {
                let count = try await notificationRepository.fetchUnreadNotificationCount()
                send(._fetchUnreadNotificationCountResult(.success(count)))
            } catch {
                send(._fetchUnreadNotificationCountResult(.failure(error)))
            }
        }
    }

    func performMarkInterestConcertToastShown() {
        Task {
            do {
                try await userRepository.markInterestConcertToastShown()
                send(._markInterestConcertToastShownResult(.success(())))
            } catch {
                send(._markInterestConcertToastShownResult(.failure(error)))
            }
        }
    }
    
    func performFetchConcertSectionData() {
        cancellables[.refreshSections]?.cancel()
        cancellables[.refreshSections] = Task {
            do {
                async let sections = concertRepository.fetchHomeConcertSectionList()
                async let recommendations = fetchRecommendationsIfNeeded()
                
                let resolvedSections = try await sections
                let resolvedRecommendations = await recommendations
                let data = (
                    sectionList: resolvedSections,
                    recommendedConcertList: resolvedRecommendations
                )
                send(._fetchConcertSectionDataResult(.success(data)))
            } catch {
                send(._fetchConcertSectionDataResult(.failure(error)))
            }
        }
    }

    func fetchRecommendationsIfNeeded() async -> [Concert]? {
        guard let hasPreferences = state.user?.hasPreferences else { return nil }
        guard hasPreferences else { return nil }

        do {
            return try await concertRepository.fetchRecommendedConcertList()
        } catch {
            return []
        }
    }
    
    func getErrorMessage(from error: Error) -> String {
        if error is CancellationError {
            return ""
        }
        
        if case let error as ConcertError = error, error == .cancelled {
            return ""
        }
        
        return error.localizedDescription
    }

    func setErrorMessage(from error: Error) {
        let message = getErrorMessage(from: error)
        state.errorMessage = message

        guard !message.isEmpty else { return }
        state.interestConcertToastMessage = ""
    }

    enum Constants {
        static let interestConcertToastMessage = "종료된 공연이 자동 정리됐어요"
    }
}
