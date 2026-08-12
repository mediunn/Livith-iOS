//
//  InterestHomeReducer.swift
//  HomeFeature
//
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

import DIContainer
import Domain

@MainActor
final class InterestHomeReducer {

    private enum CancelID {
        case appear
        case interestList
        case sections
    }

    @Injected private var userRepository: UserRepository
    @Injected private var concertRepository: ConcertRepository

    private let send: (InterestHomeIntent) -> Void
    private let waitForUser: () async -> User?
    private var cancellables = [CancelID: Task<Void, Never>]()
    private var pendingInterestResultAlertFetch = false

    init(
        send: @escaping (InterestHomeIntent) -> Void,
        waitForUser: @escaping () async -> User?
    ) {
        self.send = send
        self.waitForUser = waitForUser
    }

    @discardableResult
    func reduce(
        _ intent: InterestHomeIntent,
        state: inout InterestHomeState,
        shell: InterestHomeShellContext
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
            performInterestAppear(loadsSections: loadsSections, sort: state.interestConcertSort)
            return .none

        case .onRefresh:
            return scheduleOnRefresh(sort: state.interestConcertSort, user: shell.user)

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
                if shell.user != nil {
                    state.errorMessage = ""
                }
            case .failure(let error):
                if state.interestConcertList.isEmpty {
                    state.isInterestListLoadFailed = true
                    state.errorMessage = ""
                    clearInterestResultSheet(state: &state)
                } else {
                    setError(from: error, state: &state)
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
                state.shouldShowPreferenceBanner = !(shell.user?.hasPreferences ?? false)
                state.recommendedConcertList = data.recommendedConcertList ?? []
                state.errorMessage = ""
                if isInitialLoad {
                    performFetchInterestResultAlertList()
                }
            case .failure(let error):
                setError(from: error, state: &state)
            }
            return .none
        }
    }

    func beginInitialSectionLoad(state: inout InterestHomeState, user: User) {
        state.isSectionLoading = true
        state.needsInitialSectionLoad = false
        pendingInterestResultAlertFetch = true
        performFetchSections(user: user)
    }

    func applyHomeAppearFailure(from error: Error, state: inout InterestHomeState) {
        pendingInterestResultAlertFetch = false
        state.isSectionLoading = false
        setError(from: error, state: &state)
    }

    func applyError(from error: Error, state: inout InterestHomeState) {
        setError(from: error, state: &state)
    }
}

// MARK: - Private Helpers

private extension InterestHomeReducer {
    func scheduleOnRefresh(sort: InterestConcertSort, user: User?) -> DiscardableTask {
        performFetchSections(user: user)
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

    func performInterestAppear(loadsSections: Bool, sort: InterestConcertSort) {
        cancellables[.appear]?.cancel()

        cancellables[.appear] = Task {
            async let interestListResult = fetchInterestList(filter: .homeSection(sort: sort))
            async let sectionsResult = fetchSectionsIfNeeded(loadsSections)

            send(._interestListResult(await interestListResult))

            guard loadsSections else { return }
            await sendSectionResult(sectionsResult: await sectionsResult)
        }
    }

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
            send(._interestListResult(result))
        }
    }

    func performFetchSections(user: User?) {
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
                    recommendedConcertList: recommendedConcertList
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

    func setError(from error: Error, state: inout InterestHomeState) {
        let message = errorMessage(from: error)
        state.errorMessage = message

        guard !message.isEmpty else { return }
        clearInterestResultSheet(state: &state)
    }

    func clearInterestResultSheet(state: inout InterestHomeState) {
        state.shouldShowInterestResultSheet = false
        state.interestResultAlertList = []
    }

    func shouldPresentInterestResultSheet(for alertList: [InterestConcertEntryAlert]) -> Bool {
        !alertList.isEmpty
    }
}
