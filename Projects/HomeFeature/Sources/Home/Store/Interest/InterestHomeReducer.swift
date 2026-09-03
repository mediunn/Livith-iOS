//
//  InterestHomeReducer.swift
//  HomeFeature
//
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

import DIContainer
import Domain

// MARK: - InterestHomeState

struct InterestHomeState {
    var user: User? = nil
    var interestConcertList: [InterestConcert] = []
    var interestConcertSort: InterestConcertSort = .ticketing
    var errorMessage: String = ""
    var concertSectionList: [ConcertSection] = []
    var isSectionLoading: Bool = false
    var isInterestListLoadFailed: Bool = false
    var isInterestListRetryLoading: Bool = false
    var needsInitialSectionLoad: Bool = true
    var shouldShowPreferenceBanner: Bool = false
    var recommendedConcertList: [Concert] = []
    var shouldShowInterestResultSheet: Bool = false
    var interestResultAlertList: [InterestConcertEntryAlert] = []
}

// MARK: - InterestHomeConstants

enum InterestHomeConstants {
    static let interestListLoadFailedEmptyMessage = "콘서트 목록을\n불러오지 못했어요"
}

// MARK: - InterestHomeIntent

enum InterestHomeIntent {
    case onAppear
    case onRefresh
    case onErrorToastDisappear
    case onInterestResultSheetDismiss
    case interestConcertSortSelected(InterestConcertSort)
    case _interestListResult(Result<[InterestConcert], Error>)
    case _interestResultAlertListResult(Result<[InterestConcertEntryAlert], Error>)
    case _sectionLoadResult(Result<(sectionList: [ConcertSection], recommendedConcertList: [Concert]?, preservesRecommendations: Bool), Error>)
    case _sectionsFetched([ConcertSection])
    case _userResult(Result<User, Error>)
}

// MARK: - InterestHomeReducer

@MainActor
final class InterestHomeReducer {

    private enum CancelID {
        case appear
        case interestList
        case sections
        case completeSection
        case user
    }

    @Injected private var userRepository: UserRepository
    @Injected private var concertRepository: ConcertRepository

    private let send: (InterestHomeIntent) -> DiscardableTask
    private var cancellables = [CancelID: Task<Void, Never>]()
    private var pendingInterestResultAlertFetch = false
    private var pendingInterestSectionList: [ConcertSection]?
    private var userLoadFailed = false

    init(send: @escaping (InterestHomeIntent) -> DiscardableTask) {
        self.send = send
    }

    @discardableResult
    func reduce(
        _ intent: InterestHomeIntent,
        state: inout InterestHomeState
    ) -> DiscardableTask {
        switch intent {
        case .onAppear:
            let loadsSections = state.needsInitialSectionLoad
            if loadsSections {
                state.isSectionLoading = true
                pendingInterestResultAlertFetch = true
            }
            if state.isInterestListLoadFailed {
                state.isInterestListRetryLoading = true
            }
            performFetchUserIfNeeded(user: state.user)
            performAppear(loadsSections: loadsSections, sort: state.interestConcertSort)
            return .none

        case .onRefresh:
            if state.user == nil {
                performFetchUser()
            }
            return scheduleOnRefresh(sort: state.interestConcertSort, user: state.user)

        case .onErrorToastDisappear:
            state.errorMessage = ""
            return .none

        case .onInterestResultSheetDismiss:
            guard state.shouldShowInterestResultSheet else { return .none }
            clearInterestResultSheet(state: &state)
            return .none

        case .interestConcertSortSelected(let sort):
            guard state.interestConcertSort != sort else { return .none }
            state.interestConcertSort = sort
            performFetchInterestList(filter: .homeSection(sort: sort))
            return .none

        case ._interestListResult(let result):
            if case .failure(let error) = result, isCancellationError(error) {
                return .none
            }

            state.isInterestListRetryLoading = false

            switch result {
            case .success(let list):
                state.interestConcertList = list
                state.isInterestListLoadFailed = false
                if state.user != nil {
                    state.errorMessage = ""
                }
            case .failure(let error):
                if state.interestConcertList.isEmpty {
                    state.isInterestListLoadFailed = true
                    state.errorMessage = ""
                    clearInterestResultSheet(state: &state)
                } else {
                    applyError(from: error, state: &state)
                }
            }
            return .none

        case ._interestResultAlertListResult(let result):
            switch result {
            case .success(let alertList):
                guard shouldPresentInterestResultSheet(for: alertList) else {
                    clearInterestResultSheet(state: &state)
                    return .none
                }
                guard state.errorMessage.isEmpty, !state.isInterestListLoadFailed else {
                    clearInterestResultSheet(state: &state)
                    return .none
                }

                state.interestResultAlertList = alertList
                state.shouldShowInterestResultSheet = true
            case .failure:
                clearInterestResultSheet(state: &state)
            }
            return .none

        case ._sectionLoadResult(let result):
            if case .failure(let error) = result, isCancellationError(error) {
                return .none
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
                if !data.preservesRecommendations {
                    state.shouldShowPreferenceBanner = !(state.user?.hasPreferences ?? false)
                    state.recommendedConcertList = data.recommendedConcertList ?? []
                }
                state.errorMessage = ""
                if isInitialLoad {
                    performFetchInterestResultAlertList()
                }
            case .failure(let error):
                applyError(from: error, state: &state)
            }
            return .none

        case ._sectionsFetched(let sectionList):
            if let user = state.user {
                performCompleteSectionSuccess(sectionList: sectionList, user: user)
            } else if userLoadFailed {
                state.isSectionLoading = false
                pendingInterestResultAlertFetch = false
            } else {
                pendingInterestSectionList = sectionList
            }
            return .none

        case ._userResult(let result):
            switch result {
            case .success(let user):
                state.user = user
                userLoadFailed = false
                flushPendingSections(user: user)
            case .failure(let error):
                userLoadFailed = true
                pendingInterestSectionList = nil
                pendingInterestResultAlertFetch = false
                state.isSectionLoading = false
                applyError(from: error, state: &state)
            }
            return .none
        }
    }
}

// MARK: - Helpers

private extension InterestHomeReducer {
    func scheduleOnRefresh(sort: InterestConcertSort, user: User?) -> DiscardableTask {
        performFetchSections(user: user, preservesRecommendations: user == nil)
        performFetchInterestList(filter: .homeSection(sort: sort))

        let sectionsTask = cancellables[.sections]
        let interestListTask = cancellables[.interestList]
        let task = Task {
            await withTaskCancellationHandler {
                await sectionsTask?.value
                await interestListTask?.value
            } onCancel: {
                sectionsTask?.cancel()
                interestListTask?.cancel()
            }
        }
        return DiscardableTask(task: task)
    }

    func performAppear(loadsSections: Bool, sort: InterestConcertSort) {
        cancellables[.appear]?.cancel()
        cancellables[.completeSection]?.cancel()
        if loadsSections {
            pendingInterestSectionList = nil
        }

        cancellables[.appear] = Task {
            async let interestListResult = fetchInterestList(filter: .homeSection(sort: sort))
            async let sectionsResult = fetchSectionsIfNeeded(loadsSections)

            send(._interestListResult(await interestListResult))

            guard loadsSections else { return }
            await sendSectionsResult(sectionsResult: await sectionsResult)
        }
    }

    func sendSectionsResult(sectionsResult: Result<[ConcertSection], Error>?) async {
        if Task.isCancelled { return }
        guard let sectionsResult else { return }

        switch sectionsResult {
        case .success(let sectionList):
            send(._sectionsFetched(sectionList))
        case .failure(let error):
            if Task.isCancelled || isCancellationError(error) { return }
            send(._sectionLoadResult(.failure(error)))
        }
    }

    func flushPendingSections(user: User) {
        guard let sectionList = pendingInterestSectionList else { return }
        pendingInterestSectionList = nil
        performCompleteSectionSuccess(sectionList: sectionList, user: user)
    }

    func performCompleteSectionSuccess(sectionList: [ConcertSection], user: User) {
        cancellables[.completeSection]?.cancel()
        cancellables[.completeSection] = Task {
            await completeSectionSuccess(sectionList: sectionList, user: user)
        }
    }

    func completeSectionSuccess(sectionList: [ConcertSection], user: User) async {
        let recommendations = await fetchRecommendations(for: user)
        if Task.isCancelled { return }
        send(._sectionLoadResult(.success((
            sectionList: sectionList,
            recommendedConcertList: recommendations,
            preservesRecommendations: false
        ))))
    }

    func fetchInterestList(filter: InterestConcertListFilter) async -> Result<[InterestConcert], Error> {
        do {
            let response = try await userRepository.fetchInterestedConcertList(filter: filter)
            return .success(response.items)
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
            if Task.isCancelled { return }
            send(._interestListResult(result))
        }
    }

    func performFetchUserIfNeeded(user: User?) {
        guard user == nil, !userLoadFailed else { return }
        performFetchUser()
    }

    func performFetchUser() {
        userLoadFailed = false
        cancellables[.user]?.cancel()
        cancellables[.user] = Task {
            let result = await fetchUser()
            if Task.isCancelled { return }
            send(._userResult(result))
        }
    }

    func fetchUser() async -> Result<User, Error> {
        do {
            return .success(try await userRepository.fetchUser())
        } catch {
            return .failure(error)
        }
    }

    func performFetchSections(user: User?, preservesRecommendations: Bool) {
        cancellables[.sections]?.cancel()
        cancellables[.sections] = Task {
            do {
                async let sections = concertRepository.fetchHomeConcertSectionList()
                async let recommendations = fetchRecommendationsIfNeeded(user: user)

                let sectionList = try await sections
                if Task.isCancelled { return }
                let recommendedConcertList = await recommendations
                if Task.isCancelled { return }
                send(._sectionLoadResult(.success((
                    sectionList: sectionList,
                    recommendedConcertList: recommendedConcertList,
                    preservesRecommendations: preservesRecommendations
                ))))
            } catch {
                if Task.isCancelled || isCancellationError(error) { return }
                send(._sectionLoadResult(.failure(error)))
            }
        }
    }

    func fetchRecommendationsIfNeeded(user: User?) async -> [Concert]? {
        guard let user else { return nil }
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

    func applyError(from error: Error, state: inout InterestHomeState) {
        let message = errorMessage(from: error)
        state.errorMessage = message

        guard !message.isEmpty else { return }
        clearInterestResultSheet(state: &state)
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

    func clearInterestResultSheet(state: inout InterestHomeState) {
        state.shouldShowInterestResultSheet = false
        state.interestResultAlertList = []
    }

    func shouldPresentInterestResultSheet(for alertList: [InterestConcertEntryAlert]) -> Bool {
        !alertList.isEmpty
    }
}
