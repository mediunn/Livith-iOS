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
    var interestConcertPage: InterestConcertPage = .init(concertList: [], nextCursor: nil)
    var errorMessage: String = ""
    var hasNewNotice: Bool = false
    var concertSectionList: [ConcertSection] = []
    var isConcertSectionLoading: Bool = false
    var isConcertSectionInitialLoad: Bool = true
    var shouldShowPreferenceBanner: Bool = false
    var recommendedConcertList: [Concert] = []
}

// MARK: - Intent

enum HomeIntent {
    case onAppear
    case onRefresh
    case onErrorToastDisappear
    case checkUnreadNotification
    case _fetchInitialHomeDataResult(Result<(user: User, interestConcertPage: InterestConcertPage), Error>)
    case _fetchUserResult(Result<User, Error>)
    case _fetchInterestConcertPageResult(Result<InterestConcertPage, Error>)
    case _fetchUnreadNotificationCountResult(Result<Int, Error>)
    case _fetchConcertSectionDataResult(Result<(sectionList: [ConcertSection], recommendedConcertList: [Concert]?), Error>)
}

// MARK: - Store

@MainActor
final class HomeStore: ObservableObject {
    private enum CancelID {
        case fetchInitialHomeData
        case refreshSections
        case fetchUnreadNotificationCount
    }
    
    @Published private(set) var state: HomeState = .init()
    
    @Injected private var userRepository: UserRepository
    @Injected private var notificationRepository: NotificationRepository
    @Injected private var concertRepository: ConcertRepository
    
    private var cancellables = [CancelID: Task<Void, Never>]()

    // MARK: - Public Interface
    
    func send(_ intent: HomeIntent) {
        switch intent {
        case .onAppear:
            performFetchInitialHomeData()
            performFetchUnreadNotificationCount()

        case .onRefresh:
            performFetchConcertSectionData()

        case .onErrorToastDisappear:
            state.errorMessage = ""

        case .checkUnreadNotification:
            performFetchUnreadNotificationCount()

        case ._fetchInitialHomeDataResult(let result):
            switch result {
            case .success(let data):
                state.user = data.user
                state.interestConcertPage = data.interestConcertPage
                executeInitialConcertSectionLoadIfNeeded()
            case .failure(let error):
                state.errorMessage = getErrorMessage(from: error)
            }

        case ._fetchUserResult(let result):
            switch result {
            case .success(let user):
                state.user = user
                executeInitialConcertSectionLoadIfNeeded()
            case .failure(let error):
                state.errorMessage = getErrorMessage(from: error)
            }

        case ._fetchInterestConcertPageResult(let result):
            switch result {
            case .success(let page):
                state.interestConcertPage = page
            case .failure:
                state.interestConcertPage = .init(concertList: [], nextCursor: nil)
            }

        case ._fetchUnreadNotificationCountResult(let result):
            switch result {
            case .success(let count):
                state.hasNewNotice = count > 0
            case .failure:
                state.hasNewNotice = false
            }

        case ._fetchConcertSectionDataResult(let result):
            state.isConcertSectionLoading = false

            switch result {
            case .success(let data):
                state.concertSectionList = data.sectionList
                state.shouldShowPreferenceBanner = !(state.user?.hasPreferences ?? false)
                state.recommendedConcertList = data.recommendedConcertList ?? []
                state.errorMessage = ""
            case .failure(let error):
                state.errorMessage = getErrorMessage(from: error)
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
        performFetchConcertSectionData()
    }

    func performFetchInitialHomeData() {
        cancellables[.fetchInitialHomeData]?.cancel()
        cancellables[.fetchInitialHomeData] = Task {
            async let userResult = fetchUserResult()
            async let interestConcertPageResult = fetchInterestConcertPageResult()

            let (resolvedUserResult, resolvedInterestConcertPageResult) = await (
                userResult,
                interestConcertPageResult
            )

            switch resolvedUserResult {
            case .success(let user):
                let page = (try? resolvedInterestConcertPageResult.get()) ?? .init(concertList: [], nextCursor: nil)
                send(._fetchInitialHomeDataResult(.success((user: user, interestConcertPage: page))))
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

    func fetchInterestConcertPageResult() async -> Result<InterestConcertPage, Error> {
        do {
            let page = try await userRepository.fetchInterestedConcertList(query: .init())
            return .success(page)
        } catch {
            return .failure(error)
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
}
