//
//  InterestConcertSearchStore.swift
//  HomeFeature
//
//  Created by 김진웅 on 12/29/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import UIKit
import Foundation
import WidgetKit

import Domain
import DIContainer
import LivithFoundation

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
    case _updateInterestConcertResult(Result<Concert, Error>)
    case _imagePrefetchCompleted(UIImage?)
    case _setLoading(Bool)
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
    var completedConcert: Concert?
    var errorMessage: String = ""
    var isConcertsLoadingMore: Bool = false
    var isSearchResultsLoadingMore: Bool = false
    var isSubmitting: Bool = false
    var prefetchedPosterImage: UIImage?
    var isLoading: Bool = true
}

final class InterestConcertSearchStore: ObservableObject {
    @Published private(set) var state = InterestConcertSearchState()

    @Injected private var concertRepository: ConcertRepository
    @Injected private var userRepository: UserRepository
    @Injected private var searchRepository: SearchRepository

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
            state.selectedConcertID = nil
            state.searchList.removeAll()
            performFetchSearchList()

        case .onConcertTap(let concertID):
            state.selectedConcertID = state.selectedConcertID == concertID ? nil : concertID

        case .onSubmit:
            state.isSubmitting = true
            performPrefetchImageAndSubmit()
        
        case .onToastDisappear:
            state.errorMessage = ""
        
        case .onModeChange(let mode):
            state.mode = mode
            state.selectedConcertID = nil
        
        case .onLoadMoreConcerts:
            state.isConcertsLoadingMore = true
            performFetchConcertList(isNextPage: true)
            
        case .onLoadMoreSearchResults:
            state.isSearchResultsLoadingMore = true
            performFetchSearchList(isNextPage: true)

        case ._fetchConcertListResult(let result):
            state.isConcertsLoadingMore = false
            state.isLoading = false
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

        case ._updateInterestConcertResult(let result):
            state.isSubmitting = false
            switch result {
            case .success(let concert):
                state.completedConcert = concert
            case .failure(let error):
                state.errorMessage = error.localizedDescription
            }
        
        case ._imagePrefetchCompleted(let image):
            state.prefetchedPosterImage = image
            performUpdateInterestConcert()
        
        case ._setLoading(let isLoading):
            state.isLoading = isLoading
        }
    }
}

// MARK: - Helpers

private extension InterestConcertSearchStore {
    func performFetchConcertList(isNextPage: Bool = false) {
        Task {
            if !isNextPage {
                await send(._setLoading(true))
            }
            do {
                let concertList = try await concertRepository.fetchAllConcertList(
                    startDate: isNextPage ? state.concertList.last?.startDate : nil,
                    concertID: isNextPage ? state.concertList.last?.id : nil
                )
                await send(._fetchConcertListResult(.success(concertList)))
            } catch ConcertError.invalidResponse {
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
                let keywordList = try await searchRepository.fetchRecommendedSearchResult(keyword: state.searchText)
                await send(._fetchRecommendKeywordListResult(.success(keywordList)))
            } catch SearchError.cancelled {
                return
            } catch {
                await send(._fetchRecommendKeywordListResult(.failure(error)))
            }
        }
    }

    func performFetchSearchList(isNextPage: Bool = false) {
        Task {
            do {
                let result = try await searchRepository.fetchFilterSearchResult(
                    genre: [],
                    sort: nil,
                    status: [],
                    keyword: state.searchText,
                    cursor: isNextPage ? state.searchList.last?.id.description : nil,
                    size: nil
                )
                await send(._fetchSearchListResult(.success(result.concerts)))
            } catch SearchError.invalidResponse {
                await send(._fetchSearchListResult(.success([])))
            } catch {
                await send(._fetchSearchListResult(.failure(error)))
            }
        }
    }

    func performUpdateInterestConcert() {
        guard let concertID = state.selectedConcertID else { return }

        Task {
            do {
                let concert = try await userRepository.updateInterestedConcert(concertID)
                WidgetCenter.shared.reloadAllTimelines()
                await send(._updateInterestConcertResult(.success(concert)))
            } catch {
                await send(._updateInterestConcertResult(.failure(error)))
            }
        }
    }

    func performPrefetchImageAndSubmit() {
        guard let concertID = state.selectedConcertID else {
            Task { await send(._updateInterestConcertResult(.failure(ConcertError.cancelled))) }
            return
        }

        let concert: Concert?
        switch state.mode {
        case .initial:
            concert = state.concertList.first { $0.id == concertID }
        case .showingSearchResults:
            concert = state.searchList.first { $0.id == concertID }
        case .recommendingKeywords:
            concert = nil
        }

        guard let posterURL = concert?.posterURL else {
            Task { await send(._imagePrefetchCompleted(nil)) }
            return
        }

        Task {
            do {
                let (data, _) = try await URLSession.shared.data(from: posterURL)
                let image = UIImage(data: data)
                await send(._imagePrefetchCompleted(image))
            } catch {
                await send(._imagePrefetchCompleted(nil))
            }
        }
    }
}
