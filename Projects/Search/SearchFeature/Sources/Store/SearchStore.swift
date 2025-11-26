//
//  SearchStore.swift
//  Search
//
//  Created by Youjin Lee on 11/8/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import Foundation

import DIContainer
import SearchDomain

public struct SearchState {
    public var cursor: (title: String, id: Int)? = nil

    public var errorMessage: String = ""
    public var searchMessage: String = ""

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
    case updateSearchMessage(String)
    case sortStateChanged(SearchDomain.SearchSort)
    case resetButtonTapped
    case clearButtonTapped
    case searchButtonTapped
    case settingButtonTapped(genres: [SearchDomain.ConcertGenre], status: [SearchDomain.ConcertStatus])
    
    case _setConcertActive(Bool)
    case _setErrorMessage(String)
    case _setConcertList([SearchDomain.ConcertEntity])
}

public final class SearchStore: ObservableObject {
    @Published private(set) var state = SearchState()
    @Injected private var repository: SearchRepository

    public init() {}

    @MainActor
    public func send(_ intent: SearchIntent) {
        switch intent {
        case .viewDidLoad:
            fetchFilterSearchResult()
        case .updateSearchMessage(let message):
            state.searchMessage = message
        case .sortStateChanged(let state):
            self.state.sortState = state
            fetchFilterSearchResult()
        case .resetButtonTapped:
            state.selectedGenreList.removeAll()
            state.selectedStatusList.removeAll()
        case .clearButtonTapped:
            state.searchMessage = ""
        case .searchButtonTapped:
            fetchFilterSearchResult()
        case .settingButtonTapped(genres: let genres, status: let status):
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
    func fetchFilterSearchResult() {
        Task { @MainActor in
            let cursorText: String? = state.cursor.map { cursor in
                "{\"value\":\"\(cursor.title)\",\"id\":\(cursor.id)}"
            }

            do {
                let results = try await repository.fetchFilterSearchResult(
                    genre: state.selectedGenreList,
                    sort: state.sortState,
                    status: state.selectedStatusList,
                    keyword: state.searchMessage,
                    cursor: cursorText,
                    size: 12
                )
                
                state.isSearchActive = true
                state.searchedConcertList = results
            } catch {
                state.errorMessage = error.localizedDescription
            }
        }
    }
}
