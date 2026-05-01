//
//  InterestConcertSettingStore.swift
//  HomeFeature
//
//  Created by 김진웅 on 4/20/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

import DIContainer
import DisplaySupport
import Domain

// MARK: - State

struct InterestConcertSettingState {
    let mode: InterestConcertSettingMode
    var filteredConcertList: [Concert] = []
    var searchText: String = ""
    var isSearchFocused: Bool = false
    var selectedConcertIDList: [Int] = []
    var selectedConcertList: [Concert] = []
    var hasMoreConcertList: Bool = false
    var isInitialLoading: Bool = true
    var isLoadingMore: Bool = false
    var isSubmitting: Bool = false
    var isCTAEnabled: Bool = false
    var errorMessage: String = ""
    var successMessage: String = ""

    var selectedConcertCount: Int {
        selectedConcertIDList.count
    }
}

enum InterestConcertSettingMode {
    case initialSetup
    case update

    var navigationTitle: String {
        switch self {
        case .initialSetup:
            return "공연 설정"
        case .update:
            return "공연 변경"
        }
    }

    var ctaTitle: String {
        switch self {
        case .initialSetup:
            return "설정하기"
        case .update:
            return "변경하기"
        }
    }
}

// MARK: - Intent

enum InterestConcertSettingIntent {
    case updateSearchText(String)
    case clearSearchText
    case setSearchFocused(Bool)
    case toggleConcertSelection(Int)
    case removeSelectedConcert(Int)
    case loadNextPage
    case submit
    case clearErrorMessage
    case clearSuccessMessage
    case _fetchInitialSelectionResult(Result<ListResult<InterestConcert>, Error>)
    case _fetchFirstPageResult(Result<ListResult<Concert>, Error>)
    case _fetchNextPageResult(Result<ListResult<Concert>, Error>)
    case _submitResult(Result<[Concert], Error>)
}

// MARK: - Store

@MainActor
final class InterestConcertSettingStore: ObservableObject {

    // MARK: - Property

    @Published private(set) var state: InterestConcertSettingState

    @Injected private var concertRepository: ConcertRepository
    @Injected private var userRepository: UserRepository

    private var concertList: [Concert]
    private var initialSelectedConcertIDList: [Int]
    private var selectedConcertByID: [Int: Concert]
    private var nextToken: (any NextToken)?

    // MARK: - Initializer

    init(mode: InterestConcertSettingMode) {
        self.concertList = []
        self.initialSelectedConcertIDList = []
        self.selectedConcertByID = [:]
        self.nextToken = nil

        self.state = InterestConcertSettingState(
            mode: mode
        )
        syncSelectionState()

        performFetchInitialSelectionIfNeeded()
        performFetchFirstPage()
    }

    // MARK: - Public Interface

    func send(_ intent: InterestConcertSettingIntent) {
        switch intent {
        case .updateSearchText(let text):
            let trimmedText = trimmedSearchText(from: text)

            state.searchText = trimmedText
            applySearchFilter()
        case .clearSearchText:
            state.searchText = ""
            applySearchFilter()
            state.isSearchFocused = true
        case .setSearchFocused(let isFocused):
            state.isSearchFocused = isFocused
        case .toggleConcertSelection(let concertID):
            state.selectedConcertIDList = toggledConcertIDList(
                from: state.selectedConcertIDList,
                concertID: concertID
            )
            syncSelectionState()
        case .removeSelectedConcert(let concertID):
            state.selectedConcertIDList = removedConcertIDList(
                from: state.selectedConcertIDList,
                concertID: concertID
            )
            syncSelectionState()
        case .loadNextPage:
            guard !state.isInitialLoading,
                  !state.isLoadingMore,
                  let nextToken
            else { return }

            state.isLoadingMore = true
            performFetchNextPage(nextToken: nextToken)
        case .submit:
            guard state.isCTAEnabled, !state.isSubmitting else { return }

            state.isSubmitting = true
            state.errorMessage = ""
            state.successMessage = ""
            performSubmit()
        case .clearErrorMessage:
            state.errorMessage = ""
        case .clearSuccessMessage:
            state.successMessage = ""
        case ._fetchInitialSelectionResult(let result):
            switch result {
            case .success(let listResult):
                let selectedConcertList = listResult.items.map(\.concert)
                mergeSelectedConcerts(selectedConcertList)
                initialSelectedConcertIDList = selectedConcertList.map(\.id)
                state.selectedConcertIDList = initialSelectedConcertIDList
                syncSelectionState()
            case .failure(let error):
                state.errorMessage = error.localizedDescription
            }
        case ._fetchFirstPageResult(let result):
            state.isInitialLoading = false
            switch result {
            case .success(let listResult):
                concertList = listResult.items
                mergeSelectedConcerts(listResult.items)
                nextToken = listResult.nextToken
                state.hasMoreConcertList = listResult.nextToken != nil
                syncSelectionState()
                applySearchFilter()
            case .failure(let error):
                concertList = []
                state.filteredConcertList = []
                nextToken = nil
                state.hasMoreConcertList = false
                state.errorMessage = error.localizedDescription
            }
        case ._fetchNextPageResult(let result):
            state.isLoadingMore = false
            switch result {
            case .success(let listResult):
                concertList.append(contentsOf: listResult.items)
                mergeSelectedConcerts(listResult.items)
                nextToken = listResult.nextToken
                state.hasMoreConcertList = listResult.nextToken != nil
                syncSelectionState()
                applySearchFilter()
            case .failure(let error):
                state.errorMessage = error.localizedDescription
            }
        case ._submitResult(let result):
            state.isSubmitting = false
            switch result {
            case .success(let concertList):
                mergeSelectedConcerts(concertList)
                initialSelectedConcertIDList = state.selectedConcertIDList
                syncSelectionState()
                state.successMessage = state.mode.successMessage
            case .failure(let error):
                state.errorMessage = error.localizedDescription
            }
        }
    }
}

// MARK: - Helpers

private extension InterestConcertSettingStore {
    func performFetchInitialSelectionIfNeeded() {
        guard state.mode == .update else { return }

        let repository = userRepository

        Task {
            do {
                let result = try await repository.fetchInterestedConcertList(filter: .all)
                send(._fetchInitialSelectionResult(.success(result)))
            } catch {
                send(._fetchInitialSelectionResult(.failure(error)))
            }
        }
    }

    func performFetchFirstPage() {
        let repository = concertRepository

        Task {
            do {
                let result = try await repository.fetchAllConcertList(after: nil, size: Constants.pageSize)
                send(._fetchFirstPageResult(.success(result)))
            } catch {
                send(._fetchFirstPageResult(.failure(error)))
            }
        }
    }

    func performFetchNextPage(nextToken: any NextToken) {
        let repository = concertRepository

        Task {
            do {
                let result = try await repository.fetchAllConcertList(after: nextToken, size: Constants.pageSize)
                send(._fetchNextPageResult(.success(result)))
            } catch {
                send(._fetchNextPageResult(.failure(error)))
            }
        }
    }

    func performSubmit() {
        let repository = userRepository
        let selectedConcertIDList = state.selectedConcertIDList

        Task {
            do {
                let concertList = try await repository.updateInterestedConcertList(selectedConcertIDList)
                send(._submitResult(.success(concertList)))
            } catch {
                send(._submitResult(.failure(error)))
            }
        }
    }

    func mergeSelectedConcerts(_ concertList: [Concert]) {
        for concert in concertList {
            selectedConcertByID[concert.id] = concert
        }
    }

    func syncSelectionState() {
        state.selectedConcertList = state.selectedConcertIDList.compactMap { selectedConcertByID[$0] }
        state.isCTAEnabled = Self.isCTAEnabled(
            mode: state.mode,
            selectedConcertIDList: state.selectedConcertIDList,
            initialSelectedConcertIDList: initialSelectedConcertIDList
        )
    }

    func applySearchFilter() {
        state.filteredConcertList = filteredConcertList(
            from: concertList,
            searchText: state.searchText
        )
    }

    func trimmedSearchText(from text: String) -> String {
        text.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    func filteredConcertList(from concertList: [Concert], searchText: String) -> [Concert] {
        guard !searchText.isEmpty else { return concertList }

        return concertList.filter {
            ConcertDisplayText.title(for: $0).localizedCaseInsensitiveContains(searchText)
        }
    }

    func toggledConcertIDList(from selectedConcertIDList: [Int], concertID: Int) -> [Int] {
        guard !selectedConcertIDList.contains(concertID) else {
            return selectedConcertIDList.filter { $0 != concertID }
        }

        return selectedConcertIDList + [concertID]
    }

    func removedConcertIDList(from selectedConcertIDList: [Int], concertID: Int) -> [Int] {
        selectedConcertIDList.filter { $0 != concertID }
    }
}

private extension InterestConcertSettingStore {
    static func isCTAEnabled(
        mode: InterestConcertSettingMode,
        selectedConcertIDList: [Int],
        initialSelectedConcertIDList: [Int]
    ) -> Bool {
        switch mode {
        case .initialSetup:
            return !selectedConcertIDList.isEmpty
        case .update:
            return Set(selectedConcertIDList) != Set(initialSelectedConcertIDList)
        }
    }

    enum Constants {
        static let pageSize = 12
    }
}

private extension InterestConcertSettingMode {
    var successMessage: String {
        switch self {
        case .initialSetup:
            return "관심 콘서트를 설정했어요"
        case .update:
            return "관심 콘서트를 변경했어요"
        }
    }
}
