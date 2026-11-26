//
//  InterestConcertSettingViewModel.swift
//  HomeFeature
//
//  Created by 김진웅 on 4/20/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation
import Observation

import DisplaySupport
import Domain

enum InterestConcertSettingMode {
    case initialSetup
    case update

    var navigationTitle: String {
        switch self {
        case .initialSetup:
            return "공연 설정"
        case .update:
            return "공연 변경"
        }
    }

    var ctaTitle: String {
        switch self {
        case .initialSetup:
            return "설정하기"
        case .update:
            return "변경하기"
        }
    }
}

@MainActor
@Observable
final class InterestConcertSettingViewModel {
    let mode: InterestConcertSettingMode
    var isSearchFocused = false
    private(set) var errorMessage = ""
    var isErrorToastPresented = false
    private var pendingErrorMessage: String?
    private(set) var searchText = ""
    private(set) var isInitialLoading = true
    private(set) var isSearchLoading = false
    private(set) var isSubmitting = false

    private let concertCatalogRepository: any ConcertCatalogRepository
    private let searchRepository: any SearchRepository
    private let interestConcertRepository: any InterestConcertRepository
    private var selection = InterestConcertSelection()
    private var concertsByID: [Int: Concert] = [:]
    private var catalogConcertList: [Concert] = []
    private var catalogCursor: (any PagePosition)?
    private var searchResultList: [Concert]?
    private var searchCursor: (any PagePosition)?
    private var isLoadingCatalogPage = false
    private var isLoadingSearchPage = false
    @ObservationIgnored private var didStartLoading = false
    @ObservationIgnored private var searchRevision = 0
    @ObservationIgnored private var searchTask: Task<Void, Never>?

    init(
        mode: InterestConcertSettingMode,
        concertCatalogRepository: any ConcertCatalogRepository,
        searchRepository: any SearchRepository,
        interestConcertRepository: any InterestConcertRepository
    ) {
        self.mode = mode
        self.concertCatalogRepository = concertCatalogRepository
        self.searchRepository = searchRepository
        self.interestConcertRepository = interestConcertRepository
    }

    var selectedConcertIDList: [Int] { selection.concertIDs }
    var selectedConcertList: [Concert] { selection.concertIDs.compactMap { concertsByID[$0] } }
    var hasUnsavedChanges: Bool { selection.hasUnsavedChanges }
    var displayedConcertList: [Concert] { searchResultList ?? catalogConcertList }
    var hasMoreConcertList: Bool { keyword.isEmpty ? catalogCursor != nil : searchCursor != nil }
    var isLoadingMore: Bool { keyword.isEmpty ? isLoadingCatalogPage : isLoadingSearchPage }

    func loadIfNeeded() async {
        guard !didStartLoading else { return }
        didStartLoading = true
        async let initialSelection: Void = loadInitialSelection()
        await loadCatalogPage(after: nil)
        await initialSelection
        isInitialLoading = false
    }

    func toggleConcertSelection(_ id: Int) {
        guard !isInitialLoading else { return }
        selection.toggle(concertID: id)
    }

    func removeSelectedConcert(_ id: Int) {
        guard !isInitialLoading else { return }
        selection.remove(concertID: id)
    }

    func updateSearchText(_ text: String) {
        searchText = text
        searchRevision += 1
        searchTask?.cancel()
        searchTask = nil
        searchCursor = nil
        isSearchLoading = false
        isLoadingSearchPage = false
        let query = keyword
        guard !query.isEmpty else {
            searchResultList = nil
            return
        }

        let revision = searchRevision
        searchTask = Task { [weak self] in
            try? await Task.sleep(for: .milliseconds(300))
            guard !Task.isCancelled, let self else { return }
            isSearchLoading = true
            await loadSearchPage(query: query, after: nil, revision: revision)
        }
    }

    func clearSearchText() {
        updateSearchText("")
        isSearchFocused = true
    }

    func loadNextPage() async {
        guard !isInitialLoading, !isSearchLoading, !isLoadingMore else { return }
        if keyword.isEmpty {
            guard let catalogCursor else { return }
            isLoadingCatalogPage = true
            await loadCatalogPage(after: catalogCursor)
            isLoadingCatalogPage = false
        } else {
            guard let searchCursor else { return }
            isLoadingSearchPage = true
            let query = keyword
            let revision = searchRevision
            let request = Task {
                await loadSearchPage(query: query, after: searchCursor, revision: revision)
            }
            searchTask = request
            await withTaskCancellationHandler {
                await request.value
            } onCancel: {
                request.cancel()
            }
        }
    }

    func presentPendingErrorIfNeeded() {
        guard !isErrorToastPresented, let pendingErrorMessage else { return }
        presentError(pendingErrorMessage)
    }

    func submit() async -> Bool {
        guard hasUnsavedChanges, !isSubmitting, !isInitialLoading else { return false }
        isSubmitting = true
        defer { isSubmitting = false }

        let submittedIDs = selection.concertIDs
        do {
            let concerts = try await interestConcertRepository.updateInterestedConcertList(submittedIDs)
            remember(concerts)
            selection.markSaved(concertIDs: submittedIDs)
            return true
        } catch {
            presentError(mode.failureMessage)
            return false
        }
    }
}

private extension InterestConcertSettingViewModel {
    var keyword: String { searchText.trimmingCharacters(in: .whitespacesAndNewlines) }

    func presentError(_ message: String) {
        if isErrorToastPresented {
            pendingErrorMessage = message
            return
        }
        pendingErrorMessage = nil
        errorMessage = message
        isErrorToastPresented = true
    }

    func loadInitialSelection() async {
        guard mode == .update else { return }
        var concerts: [Concert] = []
        var cursor: (any PagePosition)?
        do {
            repeat {
                let page = try await interestConcertRepository.fetchInterestedConcertList(
                    filter: .initialSelectionPage(limit: 50, position: cursor)
                )
                concerts.append(contentsOf: page.items.map(\.concert))
                cursor = page.position
            } while cursor != nil
            remember(concerts)
            selection = InterestConcertSelection(concertIDs: concerts.map(\.id))
        } catch {
            presentError(DisplayErrorMessage.message(for: error))
        }
    }

    func loadCatalogPage(after cursor: (any PagePosition)?) async {
        do {
            let page = try await concertCatalogRepository.fetchAllConcertList(after: cursor, size: 12)
            catalogConcertList.append(contentsOf: page.items)
            catalogCursor = page.position
            remember(page.items)
        } catch {
            presentError(DisplayErrorMessage.message(for: error))
        }
    }

    func loadSearchPage(query: String, after cursor: (any PagePosition)?, revision: Int) async {
        defer {
            if revision == searchRevision {
                isSearchLoading = false
                isLoadingSearchPage = false
            }
        }
        do {
            let page = try await searchRepository.fetchFilterSearchResult(
                genre: [], sort: nil, status: [.ongoing, .upcoming],
                keyword: query, after: cursor, size: 12
            )
            guard !Task.isCancelled, revision == searchRevision else { return }
            if cursor == nil {
                searchResultList = page.items
            } else {
                searchResultList?.append(contentsOf: page.items)
            }
            searchCursor = page.position
            remember(page.items)
        } catch {
            guard !Task.isCancelled, revision == searchRevision else { return }
            searchResultList = []
            searchCursor = nil
            presentError(DisplayErrorMessage.message(for: error))
        }
    }

    func remember(_ concerts: [Concert]) {
        for concert in concerts {
            concertsByID[concert.id] = concert
        }
    }
}

extension InterestConcertSettingMode {
    var successMessage: String {
        switch self {
        case .initialSetup:
            return "소식을 받을 공연이 설정되었어요"
        case .update:
            return "소식을 받을 공연이 변경되었어요"
        }
    }

    fileprivate var failureMessage: String {
        switch self {
        case .initialSetup:
            return "소식을 받을 공연 추가에 실패했어요"
        case .update:
            return "소식을 받을 공연 변경에 실패했어요"
        }
    }
}
