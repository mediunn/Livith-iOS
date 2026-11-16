//
//  SearchStore.swift
//  Search
//
//  Created by Youjin Lee on 11/8/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import Foundation

import DIContainer
import Domain
import LivithFoundation

public struct SearchState {
    public var cursor: Int? = nil

    public var errorMessage: String = ""
    public var searchMessage: String = ""

    public var hasMorePages: Bool = true
    public var isLoadingMore: Bool = false

    public var isSortShown: Bool = false
    public var isFilterShown: Bool = false
    public var isSearchActive: Bool = false

    public var sortState: SearchSort = .latest

    public var selectedGenreList: [ConcertGenre] = []
    public var selectedStatusList: [ConcertStatus] = []
    public var searchedConcertList: [Concert] = []

    public init() {}
}

public enum SearchIntent {
    case viewDidLoad
    case loadNextPage
    case resetButtonTapped
    case clearButtonTapped
    case searchButtonTapped
    case updateSearchMessage(String)
    case sortStateChanged(SearchSort)
    case settingButtonTapped(genres: [ConcertGenre], status: [ConcertStatus])

    case _setConcertActive(Bool)
    case _setErrorMessage(String)
    case _setConcertList([Concert])
    case _searchDebounceElapsed
    case _nextPageDelayElapsed
    case _searchResult(Result<SearchResult, SearchError>, isNextPage: Bool)
}

@MainActor
final class SearchStore: ObservableObject {
    private var searchTask: Task<Void, Never>?
    private var fetchTask: Task<Void, Never>?
    @Published private(set) var state = SearchState()
    @Injected private var repository: SearchRepository

    func send(_ intent: SearchIntent) {
        switch intent {
        case .viewDidLoad:
            performSearch()
        case .loadNextPage:
            guard !state.isLoadingMore, state.hasMorePages else { return }
            state.isLoadingMore = true
            performNextPageLoad()
        case .updateSearchMessage(let newSearchMessage):
            let previousSearchMessage = state.searchMessage
            state.searchMessage = newSearchMessage
            if newSearchMessage.isEmpty && !previousSearchMessage.isEmpty {
                state.cursor = nil
                state.hasMorePages = true
                performSearch()
            }
        case .sortStateChanged(let sort):
            state.cursor = nil
            state.sortState = sort
            state.hasMorePages = true
            performSearch()
        case .resetButtonTapped:
            state.selectedGenreList.removeAll()
            state.selectedStatusList.removeAll()
        case .clearButtonTapped:
            state.searchMessage = ""
            state.cursor = nil
            state.hasMorePages = true
            performSearch()
        case .searchButtonTapped:
            performDebouncedSearch()
        case .settingButtonTapped(genres: let genres, status: let status):
            state.cursor = nil
            state.hasMorePages = true
            state.selectedGenreList = genres
            state.selectedStatusList = status
            performSearch()
        case ._setErrorMessage(let message):
            state.errorMessage = message
        case ._setConcertList(let concerts):
            state.searchedConcertList = concerts
        case ._setConcertActive(let isActive):
            state.isSearchActive = isActive
        case ._searchDebounceElapsed:
            state.cursor = nil
            state.hasMorePages = true
            performSearch()
        case ._nextPageDelayElapsed:
            performSearch(isNextPage: true)
        case ._searchResult(let result, let isNextPage):
            switch result {
            case .success(let result):
                state.isSearchActive = true
                if isNextPage {
                    state.searchedConcertList.append(contentsOf: result.concerts)
                } else {
                    state.searchedConcertList = result.concerts
                }
                state.cursor = result.cursor
                state.hasMorePages = result.cursor != nil
            case .failure(let error):
                state.errorMessage = error.localizedDescription
            }
            state.isLoadingMore = false
        }
    }
}

private extension SearchStore {
    func performNextPageLoad() {
        Task {
            try? await Task.sleep(for: .milliseconds(500))
            send(._nextPageDelayElapsed)
        }
    }
    
    func performDebouncedSearch() {
        searchTask?.cancel()
        
        searchTask = Task {
            guard await Task.wait(for: .milliseconds(300)) else { return }
            
            send(._searchDebounceElapsed)
        }
    }
    
    func performSearch(isNextPage: Bool = false) {
        if !isNextPage {
            fetchTask?.cancel()
        }

        fetchTask = Task { @MainActor in
            do throws(SearchError) {
                let result = try await repository.fetchFilterSearchResult(
                    genre: state.selectedGenreList,
                    sort: state.sortState,
                    status: state.selectedStatusList,
                    keyword: state.searchMessage,
                    cursor: state.cursor,
                    size: 12
                )

                guard await Task.wait() else { return }

                send(._searchResult(.success(result), isNextPage: isNextPage))
            } catch {
                guard await Task.wait() else { return }
                send(._searchResult(.failure(error), isNextPage: isNextPage))
            }
        }
    }
}
