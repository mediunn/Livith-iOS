//
//  InterestConcertSettingStore.swift
//  HomeFeature
//
//  Created by 김진웅 on 4/20/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

import DisplaySupport
import Domain

// MARK: - State

struct InterestConcertSettingState {
    let mode: InterestConcertSettingMode
    var displayedConcertList: [Concert] = []
    var searchText: String = ""
    var isSearchFocused: Bool = false
    var selection = InterestConcertSelection()
    var selectedConcertIDList: [Int] { selection.concertIDs }
    var selectedConcertList: [Concert] = []
    var hasMoreConcertList: Bool = false
    var isInitialLoading: Bool = true
    var isSearchLoading: Bool = false
    var isLoadingMore: Bool = false
    var isSubmitting: Bool = false
    var isCTAEnabled: Bool { selection.hasUnsavedChanges }
    var hasUnsavedChanges: Bool { selection.hasUnsavedChanges }
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
    case _fetchSearchResult(keyword: String, isNextPage: Bool, Result<ListResult<Concert>, Error>)
    case _submitResult(Result<[Concert], Error>, submittedConcertIDs: [Int])
}

// MARK: - Store

@MainActor
final class InterestConcertSettingStore: ObservableObject {

    // MARK: - Properties

    @Published private(set) var state: InterestConcertSettingState

    private let concertCatalogRepository: any ConcertCatalogRepository
    private let searchRepository: any SearchRepository
    private let interestConcertRepository: any InterestConcertRepository

    private var baseConcertList: [Concert]
    private var selectedConcertByID: [Int: Concert]
    private var basePosition: (any PagePosition)?
    private var searchPosition: (any PagePosition)?
    private var isBaseConcertListLoading: Bool {
        didSet {
            updateInitialLoadingState()
        }
    }
    private var isInitialSelectionLoading: Bool {
        didSet {
            updateInitialLoadingState()
        }
    }
    private var searchDebounceTask: Task<Void, Never>?
    private var searchFetchTask: Task<Void, Never>?

    // MARK: - Initializer

    init(
        mode: InterestConcertSettingMode,
        concertCatalogRepository: any ConcertCatalogRepository,
        searchRepository: any SearchRepository,
        interestConcertRepository: any InterestConcertRepository
    ) {
        self.concertCatalogRepository = concertCatalogRepository
        self.searchRepository = searchRepository
        self.interestConcertRepository = interestConcertRepository

        self.baseConcertList = []
        self.selectedConcertByID = [:]
        self.basePosition = nil
        self.searchPosition = nil
        self.isBaseConcertListLoading = true
        self.isInitialSelectionLoading = mode == .update

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
            state.searchText = text
            scheduleSearchIfNeeded(for: text)
        case .clearSearchText:
            state.searchText = ""
            cancelSearchTasks()
            restoreBaseConcertList()
            state.isSearchFocused = true
        case .setSearchFocused(let isFocused):
            state.isSearchFocused = isFocused
        case .toggleConcertSelection(let concertID):
            guard !state.isInitialLoading else { return }

            state.selection.toggle(concertID: concertID)
            syncSelectionState()
        case .removeSelectedConcert(let concertID):
            guard !state.isInitialLoading else { return }

            state.selection.remove(concertID: concertID)
            syncSelectionState()
        case .loadNextPage:
            guard !state.isInitialLoading, !state.isLoadingMore else { return }

            state.isLoadingMore = true
            if let keyword = currentSearchKeyword() {
                guard searchPosition != nil else {
                    state.isLoadingMore = false
                    return
                }

                performFetchSearch(keyword: keyword, isNextPage: true)
            } else {
                guard let basePosition else {
                    state.isLoadingMore = false
                    return
                }

                performFetchNextPage(position: basePosition)
            }
        case .submit:
            guard state.isCTAEnabled, !state.isSubmitting else { return }
            guard !state.isInitialLoading else { return }

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
                state.selection = InterestConcertSelection(concertIDs: selectedConcertList.map(\.id))
                syncSelectionState()
            case .failure(let error):
                state.errorMessage = DisplayErrorMessage.message(for: error)
            }
            isInitialSelectionLoading = false
        case ._fetchFirstPageResult(let result):
            switch result {
            case .success(let listResult):
                baseConcertList = listResult.items
                mergeSelectedConcerts(listResult.items)
                basePosition = listResult.position
                state.hasMoreConcertList = listResult.position != nil
                syncSelectionState()
                if currentSearchKeyword() == nil {
                    restoreBaseConcertList()
                }
            case .failure(let error):
                baseConcertList = []
                state.displayedConcertList = []
                basePosition = nil
                state.hasMoreConcertList = false
                state.errorMessage = DisplayErrorMessage.message(for: error)
            }
            isBaseConcertListLoading = false
        case ._fetchNextPageResult(let result):
            state.isLoadingMore = false
            switch result {
            case .success(let listResult):
                baseConcertList.append(contentsOf: listResult.items)
                mergeSelectedConcerts(listResult.items)
                basePosition = listResult.position
                state.hasMoreConcertList = listResult.position != nil
                syncSelectionState()
                if currentSearchKeyword() == nil {
                    restoreBaseConcertList()
                }
            case .failure(let error):
                state.errorMessage = DisplayErrorMessage.message(for: error)
            }
        case ._fetchSearchResult(let keyword, let isNextPage, let result):
            guard currentSearchKeyword() == keyword else { return }

            if !isNextPage {
                state.isSearchLoading = false
            }
            state.isLoadingMore = false
            switch result {
            case .success(let searchResult):
                mergeSelectedConcerts(searchResult.items)
                if isNextPage {
                    state.displayedConcertList.append(contentsOf: searchResult.items)
                } else {
                    state.displayedConcertList = searchResult.items
                }
                searchPosition = searchResult.position
                state.hasMoreConcertList = searchResult.position != nil
                syncSelectionState()
            case .failure(let error):
                state.displayedConcertList = []
                searchPosition = nil
                state.hasMoreConcertList = false
                state.errorMessage = DisplayErrorMessage.message(for: error)
            }
        case ._submitResult(let result, let submittedConcertIDs):
            state.isSubmitting = false
            switch result {
            case .success(let concertList):
                mergeSelectedConcerts(concertList)
                state.selection.markSaved(concertIDs: submittedConcertIDs)
                syncSelectionState()
                state.successMessage = state.mode.successMessage
            case .failure:
                state.errorMessage = state.mode.failureMessage
            }
        }
    }
}

// MARK: - Helpers

private extension InterestConcertSettingStore {
    func performFetchInitialSelectionIfNeeded() {
        guard state.mode == .update else { return }

        let repository = interestConcertRepository

        Task {
            do {
                let result = try await fetchInitialSelectionPageList(repository: repository)
                send(._fetchInitialSelectionResult(.success(result)))
            } catch {
                send(._fetchInitialSelectionResult(.failure(error)))
            }
        }
    }

    func performFetchFirstPage() {
        let repository = concertCatalogRepository

        Task {
            do {
                let result = try await repository.fetchAllConcertList(after: nil, size: Constants.pageSize)
                send(._fetchFirstPageResult(.success(result)))
            } catch {
                send(._fetchFirstPageResult(.failure(error)))
            }
        }
    }

    func performFetchNextPage(position: any PagePosition) {
        let repository = concertCatalogRepository

        Task {
            do {
                let result = try await repository.fetchAllConcertList(after: position, size: Constants.pageSize)
                send(._fetchNextPageResult(.success(result)))
            } catch {
                send(._fetchNextPageResult(.failure(error)))
            }
        }
    }

    func performFetchSearch(keyword: String, isNextPage: Bool) {
        if !isNextPage {
            searchFetchTask?.cancel()
            state.isSearchLoading = true
        }

        let repository = searchRepository
        let position = isNextPage ? searchPosition : nil

        searchFetchTask = Task {
            do {
                let result = try await repository.fetchFilterSearchResult(
                    genre: [],
                    sort: nil,
                    status: Constants.searchStatusList,
                    keyword: keyword,
                    after: position,
                    size: Constants.pageSize
                )
                guard !Task.isCancelled else { return }

                send(._fetchSearchResult(keyword: keyword, isNextPage: isNextPage, .success(result)))
            } catch is CancellationError {
                return
            } catch {
                guard !Task.isCancelled else { return }

                send(._fetchSearchResult(keyword: keyword, isNextPage: isNextPage, .failure(error)))
            }
        }
    }

    func performSubmit() {
        let repository = interestConcertRepository
        let selectedConcertIDList = state.selectedConcertIDList

        Task {
            do {
                let concertList = try await repository.updateInterestedConcertList(selectedConcertIDList)
                send(._submitResult(.success(concertList), submittedConcertIDs: selectedConcertIDList))
            } catch {
                send(._submitResult(.failure(error), submittedConcertIDs: selectedConcertIDList))
            }
        }
    }

    func fetchInitialSelectionPageList(
        repository: InterestConcertRepository
    ) async throws(UserError) -> ListResult<InterestConcert> {
        var interestConcertList: [InterestConcert] = []
        var position: (any PagePosition)?

        repeat {
            let page = try await repository.fetchInterestedConcertList(
                filter: .initialSelectionPage(
                    limit: Constants.initialSelectionPageSize,
                    position: position
                )
            )
            interestConcertList.append(contentsOf: page.items)
            position = page.position
        } while position != nil

        return ListResult(items: interestConcertList, position: nil)
    }

    func mergeSelectedConcerts(_ concertList: [Concert]) {
        for concert in concertList {
            selectedConcertByID[concert.id] = concert
        }
    }

    func syncSelectionState() {
        state.selectedConcertList = state.selectedConcertIDList.compactMap { selectedConcertByID[$0] }
    }

    func trimmedSearchText(from text: String) -> String {
        text.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    func currentSearchKeyword() -> String? {
        let keyword = trimmedSearchText(from: state.searchText)
        guard !keyword.isEmpty else { return nil }

        return keyword
    }

    func scheduleSearchIfNeeded(for text: String) {
        let keyword = trimmedSearchText(from: text)
        guard !keyword.isEmpty else {
            cancelSearchTasks()
            restoreBaseConcertList()
            return
        }

        searchDebounceTask?.cancel()
        searchFetchTask?.cancel()
        searchPosition = nil

        searchDebounceTask = Task {
            try? await Task.sleep(for: Constants.searchDebounceDuration)
            guard !Task.isCancelled else { return }

            performFetchSearch(keyword: keyword, isNextPage: false)
        }
    }

    func cancelSearchTasks() {
        searchDebounceTask?.cancel()
        searchFetchTask?.cancel()
        searchDebounceTask = nil
        searchFetchTask = nil
        searchPosition = nil
        state.isSearchLoading = false
    }

    func restoreBaseConcertList() {
        state.displayedConcertList = baseConcertList
        state.hasMoreConcertList = basePosition != nil
    }

    func updateInitialLoadingState() {
        state.isInitialLoading = isBaseConcertListLoading || isInitialSelectionLoading
    }
}

private extension InterestConcertSettingStore {
    enum Constants {
        static let pageSize = 12
        static let initialSelectionPageSize = 50
        static let searchDebounceDuration: Duration = .milliseconds(300)
        static let searchStatusList: [ConcertStatus] = [.ongoing, .upcoming]
    }
}

private extension InterestConcertSettingMode {
    var successMessage: String {
        switch self {
        case .initialSetup:
            return "소식을 받을 공연이 설정되었어요"
        case .update:
            return "소식을 받을 공연이 변경되었어요"
        }
    }

    var failureMessage: String {
        switch self {
        case .initialSetup:
            return "소식을 받을 공연 추가에 실패했어요"
        case .update:
            return "소식을 받을 공연 변경에 실패했어요"
        }
    }
}
