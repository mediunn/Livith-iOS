//
//  SearchStoreTests.swift
//  SearchFeatureTests
//
//  Copyright © 2026 Livith. All rights reserved.
//

import Combine
import Foundation
import os

import Testing

@testable import SearchFeature
import DIContainer
import Domain

@Suite("검색 상태 발행", .serialized)
@MainActor
struct SearchStoreTests {
    init() {
        DIContainer.shared.register(SearchRepositoryStub(), for: SearchRepository.self)
    }

    @Test("디바운스 이후의 검색 상태도 메인 스레드에서 발행해야 한다")
    func debouncePublishesOnMainThread() async throws {
        // Given
        let sut = SearchStore()
        let recorder = StatePublicationRecorder()
        let subscription = sut.$state.dropFirst().sink { _ in recorder.record() }
        defer { subscription.cancel() }

        // When
        sut.send(.updateSearchMessage("공연"))
        sut.send(.searchButtonTapped)
        try await waitForState { sut.state.isSearchActive }

        // Then
        #expect(recorder.count > 0)
        #expect(recorder.allOnMainThread)
        #expect(sut.state.cursor == 1)
        #expect(sut.state.searchMessage == "공연")
        #expect(sut.state.searchedConcertList.map(\.id) == [1])
    }

    @Test("다음 페이지 조회의 상태도 메인 스레드에서 발행해야 한다")
    func paginationPublishesOnMainThread() async throws {
        // Given
        let sut = SearchStore()
        sut.send(.viewDidLoad)
        try await waitForState { sut.state.cursor == 1 }
        let recorder = StatePublicationRecorder()
        let subscription = sut.$state.dropFirst().sink { _ in recorder.record() }
        defer { subscription.cancel() }

        // When
        sut.send(.loadNextPage)
        try await waitForState { !sut.state.isLoadingMore && sut.state.cursor == nil }

        // Then
        #expect(recorder.count > 0)
        #expect(recorder.allOnMainThread)
        #expect(!sut.state.hasMorePages)
        #expect(sut.state.searchedConcertList.map(\.id) == [1, 2])
    }

    @Test("다음 페이지 조회 실패도 메인 스레드에서 오류를 발행하고 로딩을 끝내야 한다")
    func paginationFailurePublishesOnMainThread() async throws {
        // Given
        let sut = SearchStore()
        sut.send(.viewDidLoad)
        try await waitForState { sut.state.cursor == 1 }
        DIContainer.shared.register(SearchRepositoryStub(error: .unknown), for: SearchRepository.self)
        let recorder = StatePublicationRecorder()
        let subscription = sut.$state.dropFirst().sink { _ in recorder.record() }
        defer { subscription.cancel() }

        // When
        sut.send(.loadNextPage)
        try await waitForState { !sut.state.errorMessage.isEmpty }

        // Then
        #expect(recorder.allOnMainThread)
        #expect(sut.state.errorMessage == SearchError.unknown.localizedDescription)
        #expect(!sut.state.isLoadingMore)
        #expect(sut.state.searchedConcertList.map(\.id) == [1])
    }
}

private extension SearchStoreTests {
    func waitForState(_ condition: @MainActor () -> Bool) async throws {
        let clock = ContinuousClock()
        let deadline = clock.now.advanced(by: .seconds(2))
        while !condition(), clock.now < deadline {
            try await Task.sleep(for: .milliseconds(10))
        }
        #expect(condition(), "검색 상태 변경이 제한 시간 안에 완료되어야 한다")
    }
}

private final class StatePublicationRecorder: @unchecked Sendable {
    private let publicationList = OSAllocatedUnfairLock(initialState: [Bool]())

    var count: Int {
        publicationList.withLock { $0.count }
    }

    var allOnMainThread: Bool {
        publicationList.withLock { $0.allSatisfy { $0 } }
    }

    func record() {
        publicationList.withLock { $0.append(Thread.isMainThread) }
    }
}

private struct SearchRepositoryStub: SearchRepository {
    let error: SearchError?

    init(error: SearchError? = nil) {
        self.error = error
    }

    func fetchBanners() async throws(SearchError) -> [Banner] { [] }

    func fetchFilterSearchResult(
        genre: [ConcertGenre],
        sort: SearchSort?,
        status: [ConcertStatus],
        keyword: String?,
        cursor: Int?,
        size: Int?
    ) async throws(SearchError) -> SearchResult {
        if let error { throw error }
        return SearchResult(
            concerts: [makeConcert(id: cursor == nil ? 1 : 2)],
            cursor: cursor == nil ? 1 : nil,
            totalCount: 2
        )
    }

    func fetchRecommendedSearchResult(keyword: String) async throws(SearchError) -> [String] { [] }
}

private extension SearchRepositoryStub {
    func makeConcert(id: Int) -> Concert {
        Concert(
            id: id,
            title: "공연 \(id)",
            artist: "아티스트",
            status: .upcoming,
            daysLeft: 10,
            startDate: Date(timeIntervalSince1970: 1_783_584_000),
            endDate: Date(timeIntervalSince1970: 1_783_670_400),
            posterURL: nil,
            venue: "공연장",
            ticketSite: "예매처",
            ticketURL: nil,
            introduction: "",
            label: nil
        )
    }
}
