//
//  InstagramMatchSearchStoreTests.swift
//  HomeFeatureTests
//
//  Created by youz2me on 7/8/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

import Testing

@testable import HomeFeature
import DIContainer
import Domain

@MainActor
struct InstagramMatchSearchStoreTests {

    // MARK: - Properties

    let container: MockDIContainer

    // MARK: - Initializer

    init() {
        self.container = MockDIContainer()
        self.container.registerDependencies()
    }

    // MARK: - Tests

    @Test("초기화 시 콘서트 첫 페이지를 조회하고 목록을 설정해야 한다")
    func 초기화_시_콘서트_첫_페이지를_조회하고_목록을_설정해야_한다() async throws {
        // Given
        container.concertRepository.concertListResultQueue = [
            .success(ListResult(items: makeConcertList([1, 2]), nextToken: TestNextToken()))
        ]

        // When
        let sut = InstagramMatchSearchStore(context: .matchFailed)
        try await waitForAsyncTask()

        // Then
        #expect(container.concertRepository.fetchAllConcertListCallCount == 1)
        #expect(sut.state.displayedConcertList.map(\.id) == [1, 2])
        #expect(sut.state.hasMoreConcertList)
        #expect(!sut.state.isInitialLoading)
    }

    @Test("검색어 입력 시 디바운스 후 검색 결과로 목록을 교체해야 한다")
    func 검색어_입력_시_디바운스_후_검색_결과로_목록을_교체해야_한다() async throws {
        // Given
        let sut = try await makeLoadedStore(concertIDList: [1, 2])
        container.searchRepository.searchResultQueue = [
            .success(SearchResult(concerts: makeConcertList([5]), cursor: nil, totalCount: 1))
        ]

        // When
        sut.send(.updateSearchText("원 오크 록"))
        try await waitForDebounceTask()

        // Then
        #expect(container.searchRepository.fetchFilterSearchResultCallCount == 1)
        #expect(container.searchRepository.fetchFilterSearchResultKeywordList.first == "원 오크 록")
        #expect(container.searchRepository.fetchFilterSearchResultStatusList.first == [.ongoing, .upcoming])
        #expect(sut.state.displayedConcertList.map(\.id) == [5])
    }

    @Test("검색어를 지우면 기본 목록을 복원해야 한다")
    func 검색어를_지우면_기본_목록을_복원해야_한다() async throws {
        // Given
        let sut = try await makeLoadedStore(concertIDList: [1, 2])
        container.searchRepository.searchResultQueue = [
            .success(SearchResult(concerts: makeConcertList([5]), cursor: nil, totalCount: 1))
        ]
        sut.send(.updateSearchText("원 오크 록"))
        try await waitForDebounceTask()

        // When
        sut.send(.clearSearchText)

        // Then
        #expect(sut.state.displayedConcertList.map(\.id) == [1, 2])
    }

    @Test("다음 페이지 로딩 중 검색어를 지우면 로딩 상태가 해제되어야 한다")
    func 다음_페이지_로딩_중_검색어를_지우면_로딩_상태가_해제되어야_한다() async throws {
        // Given
        let sut = try await makeLoadedStore(concertIDList: [1, 2])
        container.searchRepository.searchResultQueue = [
            .success(SearchResult(concerts: makeConcertList([5]), cursor: 5, totalCount: 2))
        ]
        sut.send(.updateSearchText("원 오크 록"))
        try await waitForDebounceTask()
        container.searchRepository.fetchFilterSearchResultDelayQueue = [1_000_000_000]
        sut.send(.loadNextPage)

        // When
        sut.send(.clearSearchText)

        // Then
        #expect(!sut.state.isLoadingMore)
    }

    @Test("콘서트는 한 개만 선택되어야 한다")
    func 콘서트는_한_개만_선택되어야_한다() async throws {
        // Given
        let sut = try await makeLoadedStore(concertIDList: [1, 2])

        // When
        sut.send(.selectConcert(1))
        sut.send(.selectConcert(2))

        // Then
        #expect(sut.state.selectedConcertID == 2)
        #expect(sut.state.isCTAEnabled)
    }

    @Test("등록 성공 시 성공 메시지와 함께 홈 이동 상태가 되어야 한다")
    func 등록_성공_시_성공_메시지와_함께_홈_이동_상태가_되어야_한다() async throws {
        // Given
        container.userRepository.updatedConcertStub = makeConcert(id: 1)
        let sut = try await makeLoadedStore(concertIDList: [1, 2])
        sut.send(.selectConcert(1))

        // When
        sut.send(.register)
        try await waitForAsyncTask()

        // Then
        #expect(container.userRepository.checkInterestedConcertCallCount == 1)
        #expect(container.userRepository.updateInterestedConcertCallCount == 1)
        #expect(sut.state.successMessage == "관심콘서트와 일정에 등록했어요")
        #expect(sut.state.shouldNavigateToHome)
        #expect(!sut.state.isRegistering)
    }

    @Test("등록 실패 시 실패 메시지를 노출하고 화면을 유지해야 한다")
    func 등록_실패_시_실패_메시지를_노출하고_화면을_유지해야_한다() async throws {
        // Given
        let sut = try await makeLoadedStore(concertIDList: [1, 2])
        sut.send(.selectConcert(1))

        // When
        sut.send(.register)
        try await waitForAsyncTask()

        // Then
        #expect(sut.state.errorMessage == "관심 콘서트 등록에 실패했어요\n다시 시도해주세요")
        #expect(!sut.state.shouldNavigateToHome)
        #expect(!sut.state.isRegistering)
    }

    @Test("취소하면 중단 팝업이 표시되어야 한다")
    func 취소하면_중단_팝업이_표시되어야_한다() async throws {
        // Given
        let sut = try await makeLoadedStore(concertIDList: [1])

        // When
        sut.send(.cancelTapped)

        // Then
        #expect(sut.state.isCancelModalPresented)
        #expect(!sut.state.shouldNavigateToHome)
    }

    @Test("중단 팝업에서 그만하기를 선택하면 홈 이동 상태가 되어야 한다")
    func 중단_팝업에서_그만하기를_선택하면_홈_이동_상태가_되어야_한다() async throws {
        // Given
        let sut = try await makeLoadedStore(concertIDList: [1])
        sut.send(.cancelTapped)

        // When
        sut.send(.confirmCancel)

        // Then
        #expect(sut.state.shouldNavigateToHome)
        #expect(!sut.state.isCancelModalPresented)
    }

    @Test("중단 팝업에서 잘못 눌렀어요를 선택하면 팝업만 닫아야 한다")
    func 중단_팝업에서_잘못_눌렀어요를_선택하면_팝업만_닫아야_한다() async throws {
        // Given
        let sut = try await makeLoadedStore(concertIDList: [1])
        sut.send(.cancelTapped)
        #expect(sut.state.isCancelModalPresented)

        // When
        sut.send(.dismissCancelModal)

        // Then
        #expect(!sut.state.isCancelModalPresented)
        #expect(!sut.state.shouldNavigateToHome)
    }
}

// MARK: - Helpers

private extension InstagramMatchSearchStoreTests {
    func makeLoadedStore(concertIDList: [Int]) async throws -> InstagramMatchSearchStore {
        container.concertRepository.concertListResultQueue = [
            .success(ListResult(items: makeConcertList(concertIDList), nextToken: nil))
        ]
        let store = InstagramMatchSearchStore(context: .matchFailed)
        try await waitForAsyncTask()
        return store
    }

    func makeConcertList(_ idList: [Int]) -> [Concert] {
        idList.map(makeConcert)
    }

    func makeConcert(id: Int) -> Concert {
        Concert(
            id: id,
            title: "테스트 콘서트 \(id)",
            artist: "테스트 아티스트",
            status: .upcoming,
            daysLeft: 10,
            startDate: Date(timeIntervalSince1970: 1_783_584_000 + TimeInterval(id)),
            endDate: Date(timeIntervalSince1970: 1_783_670_400 + TimeInterval(id)),
            posterURL: URL(string: "https://example.com/poster\(id).jpg"),
            venue: "테스트 공연장",
            ticketSite: "인터파크",
            ticketURL: URL(string: "https://ticket.example.com"),
            introduction: "테스트 소개",
            label: nil
        )
    }

    func waitForAsyncTask() async throws {
        try await Task.sleep(nanoseconds: 100_000_000)
    }

    func waitForDebounceTask() async throws {
        try await Task.sleep(nanoseconds: 450_000_000)
    }
}

private struct TestNextToken: NextToken {}
