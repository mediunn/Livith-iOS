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
import LivithFoundation

enum ExploreIntent {
    case onAppear
    case onRefresh
    case setCurrentPage(Int)
    case selectGenre(ConcertGenre)
    case statusListChanged([ConcertStatus])
    case sortStateChanged(SearchSort)
    case loadNextPage
    case setErrorMessage(String)
    case _fetchBannersResult(Result<[Banner], Error>)
    case _setConcertList([Concert])
    case _appendConcertList([Concert])
    case _setCursor(Int?)
    case _setLoadingMore(Bool)
}

struct ExploreState {
    var currentPage: Int = 0
    var banners: [Banner] = []

    var selectedGenre: ConcertGenre = .all
    var selectedStatusList: [ConcertStatus] = []
    var sortState: SearchSort = .latest

    var concertList: [Concert] = []
    var cursor: Int? = nil
    var hasMorePages: Bool = true
    var isLoadingMore: Bool = false

    var isLoading: Bool = false
    var errorMessage: String = ""
}

final class ExploreStore: ObservableObject {
    @Published private(set) var state: ExploreState = ExploreState()

    @Injected private var searchRepository: SearchRepository

    private var fetchTask: Task<Void, Never>? = nil

    init() {
        performInitialFetch()
    }

    @MainActor
    func send(_ intent: ExploreIntent) {
        switch intent {
        case .onAppear:
            break

        case .onRefresh:
            state.currentPage = .zero
            state.banners = []
            state.concertList = []
            state.cursor = nil
            state.hasMorePages = true
            state.errorMessage = ""

            performInitialFetch()

        case .setCurrentPage(let page):
            state.currentPage = page

        case .selectGenre(let genre):
            guard state.selectedGenre != genre else { return }
            state.selectedGenre = genre
            state.sortState = .latest
            state.cursor = nil
            state.hasMorePages = true
            performFetchConcertList()

        case .statusListChanged(let statusList):
            state.selectedStatusList = statusList
            state.sortState = .latest
            state.cursor = nil
            state.hasMorePages = true
            performFetchConcertList()

        case .sortStateChanged(let sort):
            state.sortState = sort
            state.cursor = nil
            state.hasMorePages = true
            performFetchConcertList()

        case .loadNextPage:
            loadNextPageIfNeeded()

        case .setErrorMessage(let message):
            state.errorMessage = message

        case ._fetchBannersResult(let result):
            switch result {
            case .success(let banners):
                state.banners = banners
            case .failure(let error):
                state.errorMessage = getErrorMessage(from: error)
            }

        case ._setConcertList(let concerts):
            state.concertList = concerts

        case ._appendConcertList(let concerts):
            state.concertList.append(contentsOf: concerts)

        case ._setCursor(let cursor):
            state.cursor = cursor
            state.hasMorePages = cursor != nil

        case ._setLoadingMore(let isLoadingMore):
            state.isLoadingMore = isLoadingMore
        }
    }
}

// MARK: - Helpers

private extension ExploreStore {
    func performInitialFetch() {
        fetchTask?.cancel()

        let repository = searchRepository
        let genreList: [ConcertGenre] = state.selectedGenre == .all ? [] : [state.selectedGenre]
        let statusList = state.selectedStatusList
        let sort = state.sortState

        fetchTask = Task { @MainActor in
            async let bannersResult = repository.fetchBanners()
            async let concertResult = repository.fetchFilterSearchResult(
                genre: genreList,
                sort: sort,
                status: statusList,
                keyword: nil,
                cursor: nil,
                size: 12
            )

            do {
                let banners = try await bannersResult
                send(._fetchBannersResult(.success(banners)))
            } catch is CancellationError {
                return
            } catch {
                send(._fetchBannersResult(.failure(error)))
            }

            do {
                let result = try await concertResult
                guard await Task.wait() else { return }
                send(._setConcertList(result.concerts))
                send(._setCursor(result.cursor))
                send(._setLoadingMore(false))
            } catch is CancellationError {
                return
            } catch {
                guard await Task.wait() else { return }
                send(.setErrorMessage(getErrorMessage(from: error)))
                send(._setLoadingMore(false))
            }
        }
    }

    func loadNextPageIfNeeded() {
        guard !state.isLoadingMore, state.hasMorePages else { return }
        state.isLoadingMore = true
        Task {
            try? await Task.sleep(for: .milliseconds(500))
            performFetchConcertList(isNextPage: true)
        }
    }

    func performFetchConcertList(isNextPage: Bool = false) {
        if !isNextPage {
            fetchTask?.cancel()
        }

        let repository = searchRepository
        let genreList: [ConcertGenre] = state.selectedGenre == .all ? [] : [state.selectedGenre]
        let statusList = state.selectedStatusList
        let sort = state.sortState
        let cursor = state.cursor

        fetchTask = Task { @MainActor in
            do {
                let result = try await repository.fetchFilterSearchResult(
                    genre: genreList,
                    sort: sort,
                    status: statusList,
                    keyword: nil,
                    cursor: cursor,
                    size: 12
                )

                guard await Task.wait() else { return }

                if isNextPage {
                    send(._appendConcertList(result.concerts))
                } else {
                    send(._setConcertList(result.concerts))
                }
                send(._setCursor(result.cursor))
                send(._setLoadingMore(false))
            } catch is CancellationError {
                return
            } catch {
                guard await Task.wait() else { return }
                send(.setErrorMessage(getErrorMessage(from: error)))
                send(._setLoadingMore(false))
            }
        }
    }

    func getErrorMessage(from error: Error) -> String {
        if let searchError = error as? SearchError {
            return searchError.errorDescription ?? "알 수 없는 오류가 발생했어요."
        }
        return "알 수 없는 오류가 발생했어요."
    }
}
