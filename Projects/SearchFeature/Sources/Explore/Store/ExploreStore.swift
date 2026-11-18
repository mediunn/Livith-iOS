//
//  ExploreStore.swift
//  SearchFeature
//
//  Created by 김진웅 on 12/20/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import Foundation

import DIContainer
import DisplaySupport
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
    case _setNextToken((any NextToken)?)
    case _setLoadingMore(Bool)
}

struct ExploreState {
    var currentPage: Int = 0
    var banners: [Banner] = []

    var selectedGenre: ConcertGenre = .all
    var selectedStatusList: [ConcertStatus] = []
    var sortState: SearchSort = .latest

    var concertList: [Concert] = []
    var nextToken: (any NextToken)?
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
            state.nextToken = nil
            state.isLoadingMore = false
            state.errorMessage = ""

            performInitialFetch()

        case .setCurrentPage(let page):
            state.currentPage = page

        case .selectGenre(let genre):
            guard state.selectedGenre != genre else { return }
            state.selectedGenre = genre
            state.sortState = .latest
            state.nextToken = nil
            state.isLoadingMore = false
            performFetchConcertList()

        case .statusListChanged(let statusList):
            state.selectedStatusList = statusList
            state.sortState = .latest
            state.nextToken = nil
            state.isLoadingMore = false
            performFetchConcertList()

        case .sortStateChanged(let sort):
            state.sortState = sort
            state.nextToken = nil
            state.isLoadingMore = false
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

        case ._setNextToken(let nextToken):
            state.nextToken = nextToken

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
                after: nil,
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
                send(._setConcertList(result.items))
                send(._setNextToken(result.nextToken))
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
        guard !state.isLoadingMore, let nextToken = state.nextToken else { return }
        state.isLoadingMore = true
        performFetchConcertList(after: nextToken)
    }

    func performFetchConcertList(after nextToken: (any NextToken)? = nil) {
        let isNextPage = nextToken != nil
        fetchTask?.cancel()

        let repository = searchRepository
        let genreList: [ConcertGenre] = state.selectedGenre == .all ? [] : [state.selectedGenre]
        let statusList = state.selectedStatusList
        let sort = state.sortState

        fetchTask = Task { @MainActor in
            if isNextPage, !(await Task.wait(for: .milliseconds(500))) { return }

            do {
                let result = try await repository.fetchFilterSearchResult(
                    genre: genreList,
                    sort: sort,
                    status: statusList,
                    keyword: nil,
                    after: nextToken,
                    size: 12
                )

                guard await Task.wait() else { return }

                if isNextPage {
                    send(._appendConcertList(result.items))
                } else {
                    send(._setConcertList(result.items))
                }
                send(._setNextToken(result.nextToken))
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
            return DisplayErrorMessage.message(for: searchError)
        }
        return "알 수 없는 오류가 발생했어요."
    }
}
