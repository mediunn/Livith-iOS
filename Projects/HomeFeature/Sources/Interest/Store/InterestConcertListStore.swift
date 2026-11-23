//
//  InterestConcertListStore.swift
//  HomeFeature
//
//  Created by 김진웅 on 5/1/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

import DisplaySupport
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

    private let interestConcertRepository: any InterestConcertRepository

    private var cancellables = [CancelID: Task<Void, Never>]()
    private var currentRequestID: Int = 0
    private var position: (any PagePosition)?
    private var firstPageSnapshot: (state: InterestConcertListState, position: (any PagePosition)?)?
    private let pageSize: Int = 12

    init(repository: any InterestConcertRepository) {
        self.interestConcertRepository = repository
    }

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
            guard let position else { return }

            state.isLoadingMore = true
            performFetchNextPage(position: position)

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
                position = page.position
                state.hasMorePages = page.position != nil
                state.errorMessage = ""
            case .failure(let error):
                if let snapshot = firstPageSnapshot {
                    state = snapshot.state
                    position = snapshot.position
                    firstPageSnapshot = nil
                } else if state.interestConcertList.isEmpty {
                    position = nil
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
                position = page.position
                state.hasMorePages = page.position != nil
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

        firstPageSnapshot = sort == state.selectedSort ? nil : (state, position)
        state.isInitialLoading = true
        state.isLoadingMore = false

        if firstPageSnapshot != nil {
            state.selectedSort = sort
            state.interestConcertList = []
            position = nil
            state.hasMorePages = true
        }

        cancellables[.fetchFirstPage] = Task {
            let result = await fetchInterestConcertListResult(sort: sort, position: nil)
            send(._fetchFirstPageResult(result, sort: sort, requestID: requestID))
        }
    }

    func performFetchNextPage(position: any PagePosition) {
        let requestID = currentRequestID

        cancellables[.fetchNextPage]?.cancel()
        cancellables[.fetchNextPage] = Task {
            let result = await fetchInterestConcertListResult(sort: state.selectedSort, position: position)
            send(._fetchNextPageResult(result, requestID: requestID))
        }
    }

    func fetchInterestConcertListResult(
        sort: InterestConcertSort,
        position: (any PagePosition)?
    ) async -> Result<ListResult<InterestConcert>, Error> {
        do {
            let filter = InterestConcertListFilter.page(
                sort: sort,
                limit: pageSize,
                position: position
            )
            let page = try await interestConcertRepository.fetchInterestedConcertList(filter: filter)
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

        return DisplayErrorMessage.message(for: error)
    }
}
