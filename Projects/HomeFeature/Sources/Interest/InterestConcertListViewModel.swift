//
//  InterestConcertListViewModel.swift
//  HomeFeature
//
//  Created by 김진웅 on 5/1/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation
import Observation

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

@MainActor
@Observable
final class InterestConcertListViewModel {
    private(set) var state = InterestConcertListState()

    private let interestConcertRepository: any InterestConcertRepository

    @ObservationIgnored private var firstPageTask: Task<Void, Never>?
    @ObservationIgnored private var nextPageTask: Task<Void, Never>?
    @ObservationIgnored private var currentRequestID: Int = 0
    @ObservationIgnored private var position: (any PagePosition)?
    @ObservationIgnored private var firstPageSnapshot: (state: InterestConcertListState, position: (any PagePosition)?)?
    private let pageSize: Int = 12

    init(repository: any InterestConcertRepository) {
        self.interestConcertRepository = repository
    }

    // MARK: - Public Interface

    func loadIfNeeded() {
        guard state.interestConcertList.isEmpty, !state.isInitialLoading else { return }
        performFetchFirstPage(sort: state.selectedSort)
    }

    func loadNextPage() {
        guard state.hasMorePages, !state.isInitialLoading, !state.isLoadingMore, let position else { return }
        state.isLoadingMore = true
        performFetchNextPage(position: position)
    }

    func selectSort(_ sort: InterestConcertSort) {
        guard state.selectedSort != sort else { return }
        performFetchFirstPage(sort: sort)
    }
}

// MARK: - Helpers

private extension InterestConcertListViewModel {
    func performFetchFirstPage(sort: InterestConcertSort) {
        currentRequestID += 1
        let requestID = currentRequestID

        firstPageTask?.cancel()
        nextPageTask?.cancel()

        if sort != state.selectedSort, firstPageSnapshot == nil {
            firstPageSnapshot = (state, position)
        }
        state.isInitialLoading = true
        state.isLoadingMore = false

        if firstPageSnapshot != nil {
            state.selectedSort = sort
            state.interestConcertList = []
            position = nil
            state.hasMorePages = true
        }

        firstPageTask = Task {
            let result = await fetchInterestConcertListResult(sort: sort, position: nil)
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
                    state.isInitialLoading = false
                    state.isLoadingMore = false
                    position = snapshot.position
                    firstPageSnapshot = nil
                } else if state.interestConcertList.isEmpty {
                    position = nil
                    state.hasMorePages = false
                }
                state.errorMessage = getErrorMessage(from: error)
            }
        }
    }

    func performFetchNextPage(position: any PagePosition) {
        let requestID = currentRequestID
        let sort = state.selectedSort

        nextPageTask?.cancel()
        nextPageTask = Task {
            let result = await fetchInterestConcertListResult(sort: sort, position: position)
            guard requestID == currentRequestID else { return }

            state.isLoadingMore = false

            switch result {
            case .success(let page):
                state.interestConcertList.append(contentsOf: page.items)
                self.position = page.position
                state.hasMorePages = page.position != nil
                state.errorMessage = ""
            case .failure(let error):
                state.errorMessage = getErrorMessage(from: error)
            }
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
