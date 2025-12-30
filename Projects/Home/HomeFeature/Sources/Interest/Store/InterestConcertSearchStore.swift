//
//  InterestConcertSearchStore.swift
//  HomeFeature
//
//  Created by 김진웅 on 12/29/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import Foundation

import HomeDomain
import DIContainer
import LivithConcurrency

enum InterestConcertSearchIntent {
    case onTextChange(String)
    case onSearch
    case onConcertTap(Int)
    case onSubmit
    case onToastDisappear
    case onLoadMoreConcerts
    case onLoadMoreSearchResults
    case onModeChange(InterestConcertSearchState.Mode)
    case _fetchConcertListResult(Result<[Concert], Error>)
    case _fetchRecommendKeywordListResult(Result<[String], Error>)
    case _fetchSearchListResult(Result<[Concert], Error>)
}

struct InterestConcertSearchState {
    enum Mode {
        case initial
        case recommendingKeywords
        case showingSearchResults
    }
    
    var mode: Mode = .initial
    var concertList: [Concert] = []
    var searchText: String = ""
    var recommendKeywordList: [String] = []
    var searchList: [Concert] = []
    var selectedConcertID: Int?
    var errorMessage: String = ""
    var isConcertsLoadingMore: Bool = false
    var isSearchResultsLoadingMore: Bool = false
}

final class InterestConcertSearchStore: ObservableObject {
    @Published private(set) var state = InterestConcertSearchState()

    @Injected private var repository: HomeRepository

    private var searchTask: Task<Void, Never>?
    
    init() {
        performFetchConcertList()
    }
    
    @MainActor
    func send(_ intent: InterestConcertSearchIntent) {
        switch intent {
        case .onTextChange(let text):
            state.searchList.removeAll()
            state.searchText = text

            if text.isEmpty {
                state.recommendKeywordList.removeAll()
                searchTask?.cancel()
            } else {
                performFetchRecommendKeywordList()
            }

        case .onSearch:
            guard !state.searchText.trimmingCharacters(in: .whitespaces).isEmpty else { return }
            state.mode = .showingSearchResults
            state.searchList.removeAll()
            performFetchSearchList()

        case .onConcertTap(let concertID):
            state.selectedConcertID = state.selectedConcertID == concertID ? nil : concertID

        case .onSubmit:
            break
        
        case .onToastDisappear:
            state.errorMessage = ""
        
        case .onModeChange(let mode):
            state.mode = mode
        
        case .onLoadMoreConcerts:
            state.isConcertsLoadingMore = true
            performFetchConcertList(isNextPage: true)
            
        case .onLoadMoreSearchResults:
            state.isSearchResultsLoadingMore = true
            performFetchSearchList(isNextPage: true)

        case ._fetchConcertListResult(let result):
            state.isConcertsLoadingMore = false
            switch result {
            case .success(let concertList):
                if state.concertList.isEmpty {
                    state.concertList = concertList
                } else {
                    state.concertList.append(contentsOf: concertList)
                }
            case .failure(let error):
                state.errorMessage = error.localizedDescription
            }

        case ._fetchRecommendKeywordListResult(let result):
            switch result {
            case .success(let keywordList):
                state.recommendKeywordList = keywordList
                print("Fetched recommend keywords: \(keywordList)")
            case .failure(let error):
                state.recommendKeywordList = []
                state.errorMessage = error.localizedDescription
            }

        case ._fetchSearchListResult(let result):
            state.isSearchResultsLoadingMore = false
            switch result {
            case .success(let searchList):
                if state.searchList.isEmpty {
                    state.searchList = searchList
                } else {
                    state.searchList.append(contentsOf: searchList)
                }
            case .failure(let error):
                state.errorMessage = error.localizedDescription
            }
        }
    }
}

// MARK: - Helpers

private extension InterestConcertSearchStore {
    func performFetchConcertList(isNextPage: Bool = false) {
        Task {
            do {
                let concertList = try await repository.fetchConcertList(
                    startDate: isNextPage ? state.concertList.last?.startDate : nil,
                    concertID: isNextPage ? state.concertList.last?.id : nil
                )
                await send(._fetchConcertListResult(.success(concertList)))
            } catch HomeError.noResponse {
                await send(._fetchConcertListResult(.success([])))
            } catch {
                await send(._fetchConcertListResult(.failure(error)))
            }
        }
    }

    func performFetchRecommendKeywordList() {        
        searchTask?.cancel()
        searchTask = Task {
            guard await Task.wait(for: .milliseconds(400)) else { return }

            do {
                let keywordList = try await repository.fetchRecommendKeywordList(for: state.searchText)
                await send(._fetchRecommendKeywordListResult(.success(keywordList)))
            } catch HomeError.cancelled {
                return
            } catch {
                await send(._fetchRecommendKeywordListResult(.failure(error)))
            }
        }
    }

    func performFetchSearchList(isNextPage: Bool = false) {
        Task {
            do {
                let searchList = try await repository.fetchSearchedConcertList(
                    keyword: state.searchText,
                    startDate: isNextPage ? state.searchList.last?.startDate : nil,
                    concertID: isNextPage ? state.searchList.last?.id : nil
                )
                await send(._fetchSearchListResult(.success(searchList)))
            } catch HomeError.noResponse {
                await send(._fetchSearchListResult(.success([])))
            } catch {
                await send(._fetchSearchListResult(.failure(error)))
            }
        }
    }
}
