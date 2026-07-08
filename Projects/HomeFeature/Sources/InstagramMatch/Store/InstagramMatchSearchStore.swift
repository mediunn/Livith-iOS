//
//  InstagramMatchSearchStore.swift
//  HomeFeature
//
//  Created by youz2me on 7/8/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

import DIContainer
import DisplaySupport
import Domain

// MARK: - State

struct InstagramMatchSearchState {
    let context: InstagramMatchSearchContext
    var displayedConcertList: [Concert] = []
    var searchText: String = ""
    var isSearchFocused: Bool = false
    var selectedConcertID: Int?
    var hasMoreConcertList: Bool = false
    var isInitialLoading: Bool = true
    var isSearchLoading: Bool = false
    var isLoadingMore: Bool = false
    var isRegistering: Bool = false
    var isCancelModalPresented: Bool = false
    var shouldNavigateToHome: Bool = false
    var successMessage: String = ""
    var errorMessage: String = ""

    var isCTAEnabled: Bool {
        selectedConcertID != nil
    }
}

enum InstagramMatchSearchContext: Hashable {
    case matchFailed
    case manualSearch

    var guideTitle: String {
        switch self {
        case .matchFailed:
            return "공연 정보를 불러오지 못했어요\n직접 설정이 필요해요"
        case .manualSearch:
            return "등록하려는 공연을\n직접 검색해보세요"
        }
    }
}

// MARK: - Intent

enum InstagramMatchSearchIntent {
    case updateSearchText(String)
    case clearSearchText
    case setSearchFocused(Bool)
    case selectConcert(Int)
    case loadNextPage
    case register
    case cancelTapped
    case confirmCancel
    case dismissCancelModal
    case clearErrorMessage
    case clearSuccessMessage
    case _fetchFirstPageResult(Result<ListResult<Concert>, Error>)
    case _fetchNextPageResult(Result<ListResult<Concert>, Error>)
    case _fetchSearchResult(keyword: String, isNextPage: Bool, Result<SearchResult, Error>)
    case _registerResult(concert: Concert, Result<Void, Error>)
}

// MARK: - Store

@MainActor
final class InstagramMatchSearchStore: ObservableObject {

    // MARK: - Properties

    @Published private(set) var state: InstagramMatchSearchState

    @Injected private var concertRepository: ConcertRepository
    @Injected private var searchRepository: SearchRepository
    @Injected private var userRepository: UserRepository

    private var baseConcertList: [Concert]
    private var concertByID: [Int: Concert]
    private var baseNextToken: (any NextToken)?
    private var searchCursor: Int?
    private var searchDebounceTask: Task<Void, Never>?
    private var searchFetchTask: Task<Void, Never>?

    // MARK: - Initializer

    init(context: InstagramMatchSearchContext) {
        self.baseConcertList = []
        self.concertByID = [:]
        self.baseNextToken = nil
        self.searchCursor = nil
        self.state = InstagramMatchSearchState(context: context)

        performFetchFirstPage()
    }

    // MARK: - Public Interface

    func send(_ intent: InstagramMatchSearchIntent) {
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
        case .selectConcert(let concertID):
            guard !state.isInitialLoading else { return }

            state.selectedConcertID = state.selectedConcertID == concertID ? nil : concertID
        case .loadNextPage:
            guard !state.isInitialLoading, !state.isLoadingMore else { return }

            state.isLoadingMore = true
            if let keyword = currentSearchKeyword() {
                guard searchCursor != nil else {
                    state.isLoadingMore = false
                    return
                }

                performFetchSearch(keyword: keyword, isNextPage: true)
            } else {
                guard let baseNextToken else {
                    state.isLoadingMore = false
                    return
                }

                performFetchNextPage(nextToken: baseNextToken)
            }
        case .register:
            guard state.isCTAEnabled, !state.isRegistering else { return }
            guard let concert = selectedConcert() else { return }

            state.isRegistering = true
            state.errorMessage = ""
            state.successMessage = ""
            performRegister(concert: concert)
        case .cancelTapped:
            state.isCancelModalPresented = true
        case .confirmCancel:
            state.isCancelModalPresented = false
            state.shouldNavigateToHome = true
        case .dismissCancelModal:
            state.isCancelModalPresented = false
        case .clearErrorMessage:
            state.errorMessage = ""
        case .clearSuccessMessage:
            state.successMessage = ""
        case ._fetchFirstPageResult(let result):
            switch result {
            case .success(let listResult):
                baseConcertList = listResult.items
                mergeConcertList(listResult.items)
                baseNextToken = listResult.nextToken
                state.hasMoreConcertList = listResult.nextToken != nil
                if currentSearchKeyword() == nil {
                    restoreBaseConcertList()
                }
            case .failure(let error):
                baseConcertList = []
                state.displayedConcertList = []
                baseNextToken = nil
                state.hasMoreConcertList = false
                state.errorMessage = error.localizedDescription
            }
            state.isInitialLoading = false
        case ._fetchNextPageResult(let result):
            state.isLoadingMore = false
            switch result {
            case .success(let listResult):
                baseConcertList.append(contentsOf: listResult.items)
                mergeConcertList(listResult.items)
                baseNextToken = listResult.nextToken
                state.hasMoreConcertList = listResult.nextToken != nil
                if currentSearchKeyword() == nil {
                    restoreBaseConcertList()
                }
            case .failure(let error):
                state.errorMessage = error.localizedDescription
            }
        case ._fetchSearchResult(let keyword, let isNextPage, let result):
            guard currentSearchKeyword() == keyword else { return }

            if !isNextPage {
                state.isSearchLoading = false
            }
            state.isLoadingMore = false
            switch result {
            case .success(let searchResult):
                mergeConcertList(searchResult.concerts)
                if isNextPage {
                    state.displayedConcertList.append(contentsOf: searchResult.concerts)
                } else {
                    state.displayedConcertList = searchResult.concerts
                }
                searchCursor = searchResult.cursor
                state.hasMoreConcertList = searchResult.cursor != nil
            case .failure(let error):
                state.displayedConcertList = []
                searchCursor = nil
                state.hasMoreConcertList = false
                state.errorMessage = error.localizedDescription
            }
        case ._registerResult(_, let result):
            state.isRegistering = false
            switch result {
            case .success:
                state.successMessage = Constants.registerSuccessMessage
                state.shouldNavigateToHome = true
            case .failure:
                state.errorMessage = Constants.registerFailureMessage
            }
        }
    }
}

// MARK: - Helpers

private extension InstagramMatchSearchStore {
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

    func performFetchSearch(keyword: String, isNextPage: Bool) {
        if !isNextPage {
            searchFetchTask?.cancel()
            state.isSearchLoading = true
        }

        let repository = searchRepository
        let cursor = isNextPage ? searchCursor : nil

        searchFetchTask = Task {
            do {
                let result = try await repository.fetchFilterSearchResult(
                    genre: [],
                    sort: nil,
                    status: Constants.searchStatusList,
                    keyword: keyword,
                    cursor: cursor,
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

    func performRegister(concert: Concert) {
        let repository = userRepository

        Task {
            do {
                let isAlreadyInterested = try await repository.checkInterestedConcert(id: concert.id)
                if !isAlreadyInterested {
                    try await repository.updateInterestedConcert(concert.id)
                }
                send(._registerResult(concert: concert, .success(())))
            } catch {
                send(._registerResult(concert: concert, .failure(error)))
            }
        }
    }

    func selectedConcert() -> Concert? {
        guard let selectedConcertID = state.selectedConcertID else { return nil }

        return concertByID[selectedConcertID]
    }

    func mergeConcertList(_ concertList: [Concert]) {
        for concert in concertList {
            concertByID[concert.id] = concert
        }
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
        searchCursor = nil

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
        searchCursor = nil
        state.isSearchLoading = false
    }

    func restoreBaseConcertList() {
        state.displayedConcertList = baseConcertList
        state.hasMoreConcertList = baseNextToken != nil
    }
}

private extension InstagramMatchSearchStore {
    enum Constants {
        static let pageSize = 12
        static let searchDebounceDuration: Duration = .milliseconds(300)
        static let searchStatusList: [ConcertStatus] = [.ongoing, .upcoming]
        static let registerFailureMessage = "관심 콘서트 등록에 실패했어요\n다시 시도해주세요"
        static let registerSuccessMessage = "관심콘서트와 일정에 등록했어요"
    }
}
