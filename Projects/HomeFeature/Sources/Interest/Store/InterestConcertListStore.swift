//
//  InterestConcertListStore.swift
//  HomeFeature
//
//  Created by 김진웅 on 5/1/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

import DIContainer
import Domain

// MARK: - State

struct InterestConcertListState {
    var interestConcertList: [InterestConcert] = []
    var selectedSort: InterestConcertSort = .concert
    var nextCursor: InterestConcertPageCursor? = nil
    var hasMorePages: Bool = true
    var isInitialLoading: Bool = false
    var isLoadingMore: Bool = false
    var errorMessage: String = ""
}

// MARK: - Intent

enum InterestConcertListIntent {
    case onAppear
    case loadNextPage
    case sortSelected(InterestConcertSort)
    case _fetchFirstPageResult(Result<InterestConcertPage, Error>, sort: InterestConcertSort, requestID: Int)
    case _fetchNextPageResult(Result<InterestConcertPage, Error>, requestID: Int)
}

// MARK: - Store

@MainActor
final class InterestConcertListStore: ObservableObject {
    private enum CancelID {
        case fetchFirstPage
        case fetchNextPage
    }

    @Published private(set) var state: InterestConcertListState = .init()

    @Injected private var userRepository: UserRepository

    private var cancellables = [CancelID: Task<Void, Never>]()
    private var currentRequestID: Int = 0
    private var firstPageSnapshot: InterestConcertListState?
    private let pageSize: Int = 12

    // MARK: - Public Interface

    func send(_ intent: InterestConcertListIntent) {
        switch intent {
        case .onAppear:
            guard state.interestConcertList.isEmpty else { return }

            performFetchFirstPage(sort: state.selectedSort)

        case .loadNextPage:
            guard state.hasMorePages else { return }
            guard !state.isInitialLoading else { return }
            guard !state.isLoadingMore else { return }
            guard let cursor = state.nextCursor else { return }

            state.isLoadingMore = true
            performFetchNextPage(cursor: cursor)

        case .sortSelected(let sort):
            guard state.selectedSort != sort else { return }

            performFetchFirstPage(sort: sort)

        case ._fetchFirstPageResult(let result, let sort, let requestID):
            guard requestID == currentRequestID else { return }

            state.isInitialLoading = false

            switch result {
            case .success(let page):
                firstPageSnapshot = nil
                state.selectedSort = sort
                state.interestConcertList = page.concertList
                state.nextCursor = page.nextCursor
                state.hasMorePages = page.nextCursor != nil
                state.errorMessage = ""
            case .failure(let error):
                if let snapshot = firstPageSnapshot {
                    state.interestConcertList = snapshot.interestConcertList
                    state.selectedSort = snapshot.selectedSort
                    state.nextCursor = snapshot.nextCursor
                    state.hasMorePages = snapshot.hasMorePages
                    firstPageSnapshot = nil
                } else if state.interestConcertList.isEmpty {
                    state.nextCursor = nil
                    state.hasMorePages = false
                }
                state.errorMessage = getErrorMessage(from: error)
            }

        case ._fetchNextPageResult(let result, let requestID):
            guard requestID == currentRequestID else { return }

            state.isLoadingMore = false

            switch result {
            case .success(let page):
                state.interestConcertList.append(contentsOf: page.concertList)
                state.nextCursor = page.nextCursor
                state.hasMorePages = page.nextCursor != nil
                state.errorMessage = ""
            case .failure(let error):
                state.errorMessage = getErrorMessage(from: error)
            }
        }
    }
}

// MARK: - Helpers

private extension InterestConcertListStore {
    func performFetchFirstPage(sort: InterestConcertSort) {
        currentRequestID += 1
        let requestID = currentRequestID

        cancellables[.fetchFirstPage]?.cancel()
        cancellables[.fetchNextPage]?.cancel()

        firstPageSnapshot = sort == state.selectedSort ? nil : state
        state.isInitialLoading = true
        state.isLoadingMore = false

        if firstPageSnapshot != nil {
            state.selectedSort = sort
            state.interestConcertList = []
            state.nextCursor = nil
            state.hasMorePages = true
        }

        cancellables[.fetchFirstPage] = Task {
            let result = await fetchInterestConcertPageResult(sort: sort, cursor: nil)
            send(._fetchFirstPageResult(result, sort: sort, requestID: requestID))
        }
    }

    func performFetchNextPage(cursor: InterestConcertPageCursor) {
        let requestID = currentRequestID

        cancellables[.fetchNextPage]?.cancel()
        cancellables[.fetchNextPage] = Task {
            let result = await fetchInterestConcertPageResult(sort: state.selectedSort, cursor: cursor)
            send(._fetchNextPageResult(result, requestID: requestID))
        }
    }

    func fetchInterestConcertPageResult(
        sort: InterestConcertSort,
        cursor: InterestConcertPageCursor?
    ) async -> Result<InterestConcertPage, Error> {
        do {
            let query = InterestConcertListQuery(
                sort: sort,
                pageSize: pageSize,
                cursor: cursor
            )
            let page = try await userRepository.fetchInterestedConcertList(query: query)
            return .success(page)
        } catch {
            return .failure(error)
        }
    }

    func getErrorMessage(from error: Error) -> String {
        if error is CancellationError {
            return ""
        }

        if case let error as UserError = error, error == .cancelled {
            return ""
        }

        return error.localizedDescription
    }
}
