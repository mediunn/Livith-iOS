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

@MainActor
@Observable
final class InterestConcertListViewModel {
    private(set) var isLoadingMore = false
    private(set) var errorMessage = ""

    private let repository: any InterestConcertRepository
    private var loadedConcertList: [InterestConcert] = []
    private var loadedSort: InterestConcertSort = .ticketing
    private var loadingSort: InterestConcertSort?
    private var position: (any PagePosition)?

    @ObservationIgnored private var activeRequest: Task<Void, Never>?

    init(repository: any InterestConcertRepository) {
        self.repository = repository
    }

    var interestConcertList: [InterestConcert] {
        isInitialLoading ? [] : loadedConcertList
    }

    var selectedSort: InterestConcertSort {
        loadingSort ?? loadedSort
    }

    var isInitialLoading: Bool {
        loadingSort != nil
    }

    var hasMorePages: Bool {
        isInitialLoading || position != nil
    }

    func loadIfNeeded() async {
        guard loadedConcertList.isEmpty, !isInitialLoading else { return }
        await loadPage(sort: loadedSort, after: nil)
    }

    func selectSort(_ sort: InterestConcertSort) async {
        guard sort != selectedSort else { return }
        await loadPage(sort: sort, after: nil)
    }

    func loadNextPage() async {
        guard !isInitialLoading, !isLoadingMore, let position else { return }
        await loadPage(sort: loadedSort, after: position)
    }
}

private extension InterestConcertListViewModel {
    func loadPage(sort: InterestConcertSort, after cursor: (any PagePosition)?) async {
        guard !Task.isCancelled else { return }
        activeRequest?.cancel()
        loadingSort = cursor == nil ? sort : nil
        isLoadingMore = cursor != nil

        let request = Task {
            await fetchAndApplyPage(sort: sort, after: cursor)
        }
        activeRequest = request
        await withTaskCancellationHandler {
            await request.value
        } onCancel: {
            request.cancel()
        }
        guard activeRequest == request else { return }
        activeRequest = nil
        loadingSort = nil
        isLoadingMore = false
    }

    func fetchAndApplyPage(sort: InterestConcertSort, after cursor: (any PagePosition)?) async {
        do throws(UserError) {
            let filter = InterestConcertListFilter.page(sort: sort, limit: 12, position: cursor)
            let page = try await repository.fetchInterestedConcertList(filter: filter)
            guard !Task.isCancelled else { return }

            if cursor == nil {
                loadedConcertList = page.items
                loadedSort = sort
            } else {
                loadedConcertList.append(contentsOf: page.items)
            }
            position = page.position
            errorMessage = ""
        } catch {
            guard !Task.isCancelled else { return }
            errorMessage = error == .cancelled ? "" : DisplayErrorMessage.message(for: error)
        }
    }
}
