//
//  ExploreStore.swift
//  SearchFeature
//
//  Created by 김진웅 on 12/20/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import Foundation

import SearchDomain
import DIContainer

enum ExploreIntent {
    case onRefresh
    case setCurrentPage(Int)
    case setLoading(Bool)
    case _fetchBannersResult(Result<[Banner], Error>)
    case _fetchSectionsResult(Result<[ConcertSection], Error>)
} 

struct ExploreState {
    var currentPage: Int = 0
    var banners: [Banner] = []
    var concertSections: [ConcertSection] = []
    var isLoading: Bool = false
    var errorMessage: String? = nil
}

final class ExploreStore: ObservableObject {
    @Published private(set) var state: ExploreState = ExploreState()
    
    @Injected private var repository: SearchRepository

    init() {
        fetchAll()
    }
    
    @MainActor
    func send(_ intent: ExploreIntent) {
        switch intent {
        case .onRefresh:
            state.currentPage = .zero
            state.banners = []
            state.concertSections = []
            state.isLoading = true
            state.errorMessage = nil
            
            fetchAll()
        case .setCurrentPage(let page):
            state.currentPage = page

        case .setLoading(let loading):
            state.isLoading = loading
            
        case ._fetchBannersResult(let result):
            switch result {
            case let .success(banners):
                state.banners = banners
            case .failure(let error):
                state.isLoading = false
                state.errorMessage = errorMessage(from: error)
            }
            
        case ._fetchSectionsResult(let result):
            switch result {
            case .success(let success):
                state.concertSections = success
            case .failure(let error):
                state.isLoading = false
                state.errorMessage = errorMessage(from: error)
            }
        }
    }
}

// MARK: - Helpers

private extension ExploreStore {
    func fetchAll() {
        Task {
            await send(.setLoading(true))

            async let bannersTask = repository.fetchBanners()
            async let sectionsTask = repository.fetchSections()

            do {
                let banners = try await bannersTask
                await send(._fetchBannersResult(.success(banners)))
            } catch is CancellationError {
                await send(.setLoading(false))
            } catch {
                await send(._fetchBannersResult(.failure(error)))
            }

            do {
                let sections = try await sectionsTask
                await send(._fetchSectionsResult(.success(sections)))
            } catch is CancellationError {
                await send(.setLoading(false))
            } catch {
                await send(._fetchSectionsResult(.failure(error)))
            }
        }
    }

    func errorMessage(from error: Error) -> String? {
        guard let searchError = error as? SearchError else {
            return SearchError.unknown.errorDescription
        }

        switch searchError {
        case .networkError, .serverError:
            return searchError.errorDescription
        case .noSearchResult, .invalidResponse, .unknown:
            return SearchError.unknown.errorDescription
        }
    }
}
