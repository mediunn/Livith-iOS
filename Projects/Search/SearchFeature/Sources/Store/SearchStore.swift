//
//  SearchStore.swift
//  Search
//
//  Created by Youjin Lee on 11/8/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import Foundation

import LivithConcurrency
import DIContainer
import SearchDomain

public struct SearchState {
    public var cursor: (value: String, id: Int)? = nil

    public var errorMessage: String = ""
    public var searchMessage: String = ""
    
    public var hasMorePages: Bool = true
    public var isLoadingMore: Bool = false

    public var isSortShown: Bool = false
    public var isFilterShown: Bool = false
    public var isSearchActive: Bool = false

    public var sortState: SearchDomain.SearchSort = .latest

    public var selectedGenreList: [SearchDomain.ConcertGenre] = []
    public var selectedStatusList: [SearchDomain.ConcertStatus] = []
    public var searchedConcertList: [SearchDomain.ConcertEntity] = []

    public init() {}
}

public enum SearchIntent {
    case viewDidLoad
    case loadNextPage
    case resetButtonTapped
    case clearButtonTapped
    case searchButtonTapped
    case updateSearchMessage(String)
    case sortStateChanged(SearchDomain.SearchSort)
    case settingButtonTapped(genres: [SearchDomain.ConcertGenre], status: [SearchDomain.ConcertStatus])
    
    case _setConcertActive(Bool)
    case _setErrorMessage(String)
    case _setConcertList([SearchDomain.ConcertEntity])
}

public final class SearchStore: ObservableObject {
    private var searchTask: Task<Void, Never>?
    private var fetchTask: Task<Void, Never>?
    @Published private(set) var state = SearchState()
    @Injected private var repository: SearchRepository

    public init() {}

    @MainActor
    public func send(_ intent: SearchIntent) {
        switch intent {
        case .viewDidLoad:
            fetchFilterSearchResult()
        case .loadNextPage:
            loadNextPageIfNeeded()
        case .updateSearchMessage(let message):
            state.searchMessage = message
        case .sortStateChanged(let sort):
            state.cursor = nil
            state.sortState = sort
            state.hasMorePages = true
            fetchFilterSearchResult()
        case .resetButtonTapped:
            state.selectedGenreList.removeAll()
            state.selectedStatusList.removeAll()
        case .clearButtonTapped:
            state.searchMessage = ""
            state.cursor = nil
            state.hasMorePages = true
            fetchFilterSearchResult()
        case .searchButtonTapped:
            searchWithDebounce()
        case .settingButtonTapped(genres: let genres, status: let status):
            state.cursor = nil
            state.hasMorePages = true
            state.selectedGenreList = genres
            state.selectedStatusList = status
            fetchFilterSearchResult()
        case ._setErrorMessage(let message):
            state.errorMessage = message
        case ._setConcertList(let concerts):
            state.searchedConcertList = concerts
        case ._setConcertActive(let isActive):
            state.isSearchActive = isActive
        }
    }
}

private extension SearchStore {
    func loadNextPageIfNeeded() {
        guard !state.isLoadingMore, state.hasMorePages else { return }
        state.isLoadingMore = true
        Task {
            try? await Task.sleep(for: .milliseconds(500))
            fetchFilterSearchResult(isNextPage: true)
        }
    }
    
    func searchWithDebounce() {
        searchTask?.cancel()
        
        searchTask = Task {
            guard await Task.wait(for: .milliseconds(300)) else { return }
            
            state.cursor = nil
            state.hasMorePages = true
            fetchFilterSearchResult()
        }
    }
    
    func fetchFilterSearchResult(isNextPage: Bool = false) {
        if !isNextPage {
            fetchTask?.cancel()
        }

        fetchTask = Task { @MainActor in
            let cursorText: String? = state.cursor.map { cursor in
                "{\"value\":\"\(cursor.value)\",\"id\":\(cursor.id)}"
            }

            do {
                let result = try await repository.fetchFilterSearchResult(
                    genre: state.selectedGenreList,
                    sort: state.sortState,
                    status: state.selectedStatusList,
                    keyword: state.searchMessage,
                    cursor: cursorText,
                    size: 12
                )

                guard await Task.wait() else { return }

                state.isSearchActive = true

                if isNextPage {
                    state.searchedConcertList.append(contentsOf: result.concerts)
                } else {
                    state.searchedConcertList = result.concerts
                }

                state.cursor = result.cursor
                state.hasMorePages = result.cursor != nil
                state.isLoadingMore = false
            } catch {
                guard await Task.wait() else { return }
                state.errorMessage = error.localizedDescription
                state.isLoadingMore = false
            }
        }
    }
}
