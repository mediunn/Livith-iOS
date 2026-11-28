//
//  InstagramManualSearchViewModel.swift
//  HomeFeature
//
//  Created by youz2me on 7/8/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation
import Observation

import ConcertSearch
import DisplaySupport
import Domain

enum InstagramManualSearchContext: Hashable {
    case matchFailed
    case manualSearch

    var guideTitle: String {
        switch self {
        case .matchFailed:
            return "공연 정보를 불러오지 못했어요\n직접 설정이 필요해요"
        case .manualSearch:
            return "등록하려는 공연을\n직접 검색해보세요"
        }
    }
}

@MainActor
@Observable
final class InstagramManualSearchViewModel {
    private(set) var selectedConcertID: Int?
    private(set) var isInitialLoading = true
    var isSearchLoading: Bool { concertSearch.isLoadingFirstPage }
    private(set) var didRegister = false
    private var registrationTask: Task<Bool, Never>?
    var isRegistering: Bool { registrationTask != nil }
    private(set) var errorMessage = ""
    var isErrorToastPresented = false
    private var pendingErrorMessage: String?

    var searchText = "" {
        didSet {
            guard keyword != oldValue.trimmingCharacters(in: .whitespacesAndNewlines) else { return }
            searchRevision += 1
            if keyword.isEmpty {
                concertSearch.reset()
            } else {
                concertSearch.invalidateSearch()
            }
        }
    }
    private(set) var searchRevision = 0

    private let concertCatalogRepository: any ConcertCatalogRepository
    private let concertSearch: ConcertSearchViewModel
    private let interestConcertRepository: any InterestConcertRepository
    private var catalogList: [Concert] = []
    private var catalogCursor: (any PagePosition)?
    private var isLoadingCatalogPage = false
    private var completedSearchRevision: Int?

    init(
        concertCatalogRepository: any ConcertCatalogRepository,
        searchRepository: any SearchRepository,
        interestConcertRepository: any InterestConcertRepository
    ) {
        self.concertCatalogRepository = concertCatalogRepository
        self.concertSearch = ConcertSearchViewModel(repository: searchRepository, failurePolicy: .clearResults)
        self.interestConcertRepository = interestConcertRepository
    }

    var displayedConcertList: [Concert] { concertSearch.concertList ?? catalogList }
    var isLoadingMore: Bool { keyword.isEmpty ? isLoadingCatalogPage : concertSearch.isLoadingNextPage }
    var canRegister: Bool { selectedConcertID != nil && !isRegistering && !didRegister }

    func loadIfNeeded() async {
        guard isInitialLoading, !isLoadingCatalogPage else { return }
        await loadCatalogPage(after: nil)
        isInitialLoading = false
    }

    func searchIfNeeded() async {
        let revision = searchRevision
        guard !keyword.isEmpty, completedSearchRevision != revision else { return }
        try? await Task.sleep(for: .milliseconds(300))
        guard !Task.isCancelled, revision == searchRevision else { return }

        guard let result = await concertSearch.search(.init(keyword: keyword, statusList: [.ongoing, .upcoming])),
              revision == searchRevision else { return }
        presentSearchError(result)
        completedSearchRevision = revision
    }

    func loadNextPage() async {
        guard !isInitialLoading else { return }
        if keyword.isEmpty {
            guard !isLoadingCatalogPage, let catalogCursor else { return }
            await loadCatalogPage(after: catalogCursor)
        } else if let result = await concertSearch.loadNextPage() {
            presentSearchError(result)
        }
    }

    func toggleConcertSelection(_ id: Int) {
        guard !isInitialLoading, !isRegistering else { return }
        selectedConcertID = selectedConcertID == id ? nil : id
    }

    func presentPendingErrorIfNeeded() {
        guard !isErrorToastPresented, let pendingErrorMessage else { return }
        presentError(pendingErrorMessage)
    }

    @discardableResult
    func register() async -> Bool {
        guard canRegister, let selectedConcertID else { return false }
        let request = Task { await registerConcert(id: selectedConcertID) }
        registrationTask = request
        defer { registrationTask = nil }
        didRegister = await request.value
        return didRegister
    }
}

private extension InstagramManualSearchViewModel {
    var keyword: String { searchText.trimmingCharacters(in: .whitespacesAndNewlines) }

    func registerConcert(id: Int) async -> Bool {
        do {
            let alreadyInterested = try await interestConcertRepository.checkInterestedConcert(id: id)
            if !alreadyInterested {
                try await interestConcertRepository.updateInterestedConcert(id)
            }
            return true
        } catch {
            presentError("관심 콘서트 등록에 실패했어요\n다시 시도해주세요")
            return false
        }
    }

    func loadCatalogPage(after cursor: (any PagePosition)?) async {
        isLoadingCatalogPage = true
        defer { isLoadingCatalogPage = false }
        do {
            let page = try await concertCatalogRepository.fetchAllConcertList(after: cursor, size: 12)
            catalogList.append(contentsOf: page.items)
            catalogCursor = page.position
        } catch {
            presentError(DisplayErrorMessage.message(for: error))
        }
    }

    func presentSearchError(_ result: Result<[Concert], SearchError>) {
        if case .failure(let error) = result {
            presentError(DisplayErrorMessage.message(for: error))
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
}
