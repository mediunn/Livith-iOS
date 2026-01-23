//
//  ExploreStore.swift
//  SearchFeature
//
//  Created by 김진웅 on 12/20/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import Foundation

import DIContainer
import Domain

enum ExploreIntent {
    case onRefresh
    case setCurrentPage(Int)
    case setErrorMessage(String)
    case _fetchBannersResult(Result<[Banner], Error>)
    case _fetchSectionsResult(Result<[ConcertSection], Error>)
}

struct ExploreState {
    var currentPage: Int = 0
    var banners: [Banner] = []
    var concertSections: [ConcertSection] = []
    var isLoading: Bool = false
    var errorMessage: String = ""
}

final class ExploreStore: ObservableObject {
    @Published private(set) var state: ExploreState = ExploreState()

    @Injected private var searchRepository: SearchRepository
    @Injected private var concertRepository: ConcertRepository

    private var fetchTask: Task<Void, Never>? = nil

    init() {
        performFetchExploreData()
    }

    @MainActor
    func send(_ intent: ExploreIntent) {
        switch intent {
        case .onRefresh:
            state.currentPage = .zero
            state.banners = []
            state.concertSections = []
            state.isLoading = true
            state.errorMessage = ""

            performFetchExploreData()

        case .setCurrentPage(let page):
            state.currentPage = page

        case .setErrorMessage(let message):
            state.errorMessage = message

        case ._fetchBannersResult(let result):
            state.isLoading = false
            switch result {
            case let .success(banners):
                state.banners = banners
            case .failure(let error):
                state.errorMessage = getErrorMessage(from: error)
            }

        case ._fetchSectionsResult(let result):
            state.isLoading = false
            switch result {
            case .success(let success):
                state.concertSections = success
            case .failure(let error):
                state.errorMessage = getErrorMessage(from: error)
            }
        }
    }
}

// MARK: - Helpers

private extension ExploreStore {
    func performFetchExploreData() {
        fetchTask?.cancel()

        let searchRepo = searchRepository
        let concertRepo = concertRepository

        fetchTask = Task {
            async let bannersTask = searchRepo.fetchBanners()
            async let sectionsTask = concertRepo.fetchSearchConcertSectionList()

            do {
                let banners = try await bannersTask
                await send(._fetchBannersResult(.success(banners)))
            } catch is CancellationError {
                return
            } catch {
                await send(._fetchBannersResult(.failure(error)))
            }

            do {
                let sections = try await sectionsTask
                await send(._fetchSectionsResult(.success(sections)))
            } catch is CancellationError {
                return
            } catch {
                await send(._fetchSectionsResult(.failure(error)))
            }
        }
    }

    func getErrorMessage(from error: Error) -> String {
        if let searchError = error as? SearchError {
            return searchError.errorDescription ?? "알 수 없는 오류가 발생했어요."
        }
        if let concertError = error as? ConcertError {
            return concertError.errorDescription ?? "알 수 없는 오류가 발생했어요."
        }
        return "알 수 없는 오류가 발생했어요."
    }
}
