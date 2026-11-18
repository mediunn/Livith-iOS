//
//  SearchStore.swift
//  Search
//
//  Created by Youjin Lee on 11/8/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import Foundation

import DIContainer
import DisplaySupport
import Domain
import LivithFoundation

public struct SearchState {
    var nextToken: (any NextToken)?

    public var errorMessage: String = ""
    public var searchMessage: String = ""

    public var hasMorePages: Bool { nextToken != nil }
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
    case _searchResult(Result<ListResult<Concert>, SearchError>, isNextPage: Bool)
}

@MainActor
final class SearchStore: ObservableObject {
    private var searchTask: Task<Void, Never>?
    private var fetchTask: Task<Void, Never>?
    private var submittedKeyword = ""
    @Published private(set) var state = SearchState()
    @Injected private var repository: SearchRepository

    func send(_ intent: SearchIntent) {
        switch intent {
        case .viewDidLoad:
            performSearch()
        case .loadNextPage:
            guard !state.isLoadingMore, let nextToken = state.nextToken else { return }
            state.isLoadingMore = true
            performSearch(after: nextToken)
        case .updateSearchMessage(let newSearchMessage):
            let previousSearchMessage = state.searchMessage
            state.searchMessage = newSearchMessage
            if newSearchMessage.isEmpty && !previousSearchMessage.isEmpty {
                performSearch()
            }
        case .sortStateChanged(let sort):
            state.sortState = sort
            performSearch()
        case .resetButtonTapped:
            state.selectedGenreList.removeAll()
            state.selectedStatusList.removeAll()
        case .clearButtonTapped:
            state.searchMessage = ""
            performSearch()
        case .searchButtonTapped:
            performDebouncedSearch()
        case .settingButtonTapped(genres: let genres, status: let status):
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
            performSearch()
        case ._searchResult(let result, let isNextPage):
            switch result {
            case .success(let result):
                state.isSearchActive = true
                if isNextPage {
                    state.searchedConcertList.append(contentsOf: result.items)
                } else {
                    state.searchedConcertList = result.items
                }
                state.nextToken = result.nextToken
            case .failure(let error):
                state.errorMessage = DisplayErrorMessage.message(for: error)
            }
            state.isLoadingMore = false
        }
    }
}

private extension SearchStore {
    func performDebouncedSearch() {
        searchTask?.cancel()
        
        searchTask = Task {
            guard await Task.wait(for: .milliseconds(300)) else { return }
            
            send(._searchDebounceElapsed)
        }
    }
    
    func performSearch(after nextToken: (any NextToken)? = nil) {
        let isNextPage = nextToken != nil
        fetchTask?.cancel()
        if !isNextPage {
            submittedKeyword = state.searchMessage
            state.nextToken = nil
            state.isLoadingMore = false
        }

        let keyword = submittedKeyword
        fetchTask = Task { @MainActor in
            if isNextPage, !(await Task.wait(for: .milliseconds(500))) { return }

            do throws(SearchError) {
                let result = try await repository.fetchFilterSearchResult(
                    genre: state.selectedGenreList,
                    sort: state.sortState,
                    status: state.selectedStatusList,
                    keyword: keyword,
                    after: nextToken,
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
