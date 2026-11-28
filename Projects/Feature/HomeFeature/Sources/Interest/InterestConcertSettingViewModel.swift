//
//  InterestConcertSettingViewModel.swift
//  HomeFeature
//
//  Created by 김진웅 on 4/20/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation
import Observation

import ConcertSearch
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
    var isSearchLoading: Bool { concertSearch.isLoadingFirstPage }
    private(set) var didSave = false
    private var submissionTask: Task<Bool, Never>?
    var isSubmitting: Bool { submissionTask != nil }

    private let concertCatalogRepository: any ConcertCatalogRepository
    private let concertSearch: ConcertSearchViewModel
    private let interestConcertRepository: any InterestConcertRepository
    private var selection = InterestConcertSelection()
    private var concertsByID: [Int: Concert] = [:]
    private var catalogConcertList: [Concert] = []
    private var catalogCursor: (any PagePosition)?
    private var isLoadingCatalogPage = false
    @ObservationIgnored private var didStartLoading = false
    @ObservationIgnored private var searchDebounceTask: Task<Void, Never>?

    init(
        mode: InterestConcertSettingMode,
        concertCatalogRepository: any ConcertCatalogRepository,
        searchRepository: any SearchRepository,
        interestConcertRepository: any InterestConcertRepository
    ) {
        self.mode = mode
        self.concertCatalogRepository = concertCatalogRepository
        self.concertSearch = ConcertSearchViewModel(repository: searchRepository, failurePolicy: .clearResults)
        self.interestConcertRepository = interestConcertRepository
    }

    var selectedConcertIDList: [Int] { selection.concertIDs }
    var selectedConcertList: [Concert] { selection.concertIDs.compactMap { concertsByID[$0] } }
    var hasUnsavedChanges: Bool { selection.hasUnsavedChanges }
    var displayedConcertList: [Concert] { concertSearch.concertList ?? catalogConcertList }
    var hasMoreConcertList: Bool { keyword.isEmpty ? catalogCursor != nil : concertSearch.hasNextPage }
    var isLoadingMore: Bool { keyword.isEmpty ? isLoadingCatalogPage : concertSearch.isLoadingNextPage }

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
        searchDebounceTask?.cancel()
        searchDebounceTask = nil
        let query = keyword
        guard !query.isEmpty else {
            concertSearch.reset()
            return
        }

        concertSearch.invalidateSearch()
        searchDebounceTask = Task { [weak self] in
            try? await Task.sleep(for: .milliseconds(300))
            guard !Task.isCancelled, let concertSearch = self?.concertSearch else { return }
            if let result = await concertSearch.search(.init(keyword: query, statusList: [.ongoing, .upcoming])) {
                self?.applySearchResult(result)
            }
        }
    }

    func clearSearchText() {
        updateSearchText("")
        isSearchFocused = true
    }

    func loadNextPage() async {
        guard !isInitialLoading else { return }
        if keyword.isEmpty {
            guard !isLoadingCatalogPage, let catalogCursor else { return }
            isLoadingCatalogPage = true
            await loadCatalogPage(after: catalogCursor)
            isLoadingCatalogPage = false
        } else if let result = await concertSearch.loadNextPage() {
            applySearchResult(result)
        }
    }

    func presentPendingErrorIfNeeded() {
        guard !isErrorToastPresented, let pendingErrorMessage else { return }
        presentError(pendingErrorMessage)
    }

    @discardableResult
    func submit() async -> Bool {
        guard hasUnsavedChanges, !isSubmitting, !isInitialLoading else { return false }
        didSave = false
        let submittedIDs = selection.concertIDs
        let request = Task { await saveSelection(concertIDs: submittedIDs) }
        submissionTask = request
        defer { submissionTask = nil }
        didSave = await request.value
        return didSave
    }
}

private extension InterestConcertSettingViewModel {
    var keyword: String { searchText.trimmingCharacters(in: .whitespacesAndNewlines) }

    func saveSelection(concertIDs submittedIDs: [Int]) async -> Bool {
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

    func applySearchResult(_ result: Result<[Concert], SearchError>) {
        switch result {
        case .success(let concerts):
            remember(concerts)
        case .failure(let error):
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
