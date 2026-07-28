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
    var selectedSort: InterestConcertSort = .ticketing
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
    case _fetchFirstPageResult(Result<ListResult<InterestConcert>, Error>, sort: InterestConcertSort, requestID: Int)
    case _fetchNextPageResult(Result<ListResult<InterestConcert>, Error>, requestID: Int)
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
    private var nextToken: (any NextToken)?
    private var firstPageSnapshot: (state: InterestConcertListState, nextToken: (any NextToken)?)?
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
            guard let nextToken else { return }

            state.isLoadingMore = true
            performFetchNextPage(nextToken: nextToken)

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
                state.interestConcertList = page.items
                nextToken = page.nextToken
                state.hasMorePages = page.nextToken != nil
                state.errorMessage = ""
            case .failure(let error):
                if let snapshot = firstPageSnapshot {
                    state = snapshot.state
                    nextToken = snapshot.nextToken
                    firstPageSnapshot = nil
                } else if state.interestConcertList.isEmpty {
                    nextToken = nil
                    state.hasMorePages = false
                }
                state.errorMessage = getErrorMessage(from: error)
            }

        case ._fetchNextPageResult(let result, let requestID):
            guard requestID == currentRequestID else { return }

            state.isLoadingMore = false

            switch result {
            case .success(let page):
                state.interestConcertList.append(contentsOf: page.items)
                nextToken = page.nextToken
                state.hasMorePages = page.nextToken != nil
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

        firstPageSnapshot = sort == state.selectedSort ? nil : (state, nextToken)
        state.isInitialLoading = true
        state.isLoadingMore = false

        if firstPageSnapshot != nil {
            state.selectedSort = sort
            state.interestConcertList = []
            nextToken = nil
            state.hasMorePages = true
        }

        cancellables[.fetchFirstPage] = Task {
            let result = await fetchInterestConcertListResult(sort: sort, nextToken: nil)
            send(._fetchFirstPageResult(result, sort: sort, requestID: requestID))
        }
    }

    func performFetchNextPage(nextToken: any NextToken) {
        let requestID = currentRequestID

        cancellables[.fetchNextPage]?.cancel()
        cancellables[.fetchNextPage] = Task {
            let result = await fetchInterestConcertListResult(sort: state.selectedSort, nextToken: nextToken)
            send(._fetchNextPageResult(result, requestID: requestID))
        }
    }

    func fetchInterestConcertListResult(
        sort: InterestConcertSort,
        nextToken: (any NextToken)?
    ) async -> Result<ListResult<InterestConcert>, Error> {
        do {
            let filter = InterestConcertListFilter.page(
                sort: sort,
                limit: pageSize,
                nextToken: nextToken
            )
            let page = try await userRepository.fetchInterestedConcertList(filter: filter)
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
