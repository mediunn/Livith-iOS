//
//  InterestConcertListViewModelTests.swift
//  HomeFeatureTests
//
//  Created by 김진웅 on 5/1/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

import Testing

@testable import HomeFeature
import Domain

@MainActor
struct InterestConcertListViewModelTests {

    // MARK: - Properties

    let repository = MockUserRepository()

    // MARK: - Tests

    @Test("onAppear 시 첫 페이지를 기본 정렬과 12개 페이지 크기로 조회해야 한다")
    func onAppear는_첫_페이지를_기본_정렬과_12개_페이지_크기로_조회해야_한다() async throws {
        // Given
        let position = makePosition(id: 2)
        repository.interestConcertListResultQueue = [
            .success(makeListResult(concertIDList: [1, 2], position: position))
        ]
        let sut = InterestConcertListViewModel(repository: repository)

        // When
        await sut.loadIfNeeded()

        // Then
        #expect(repository.fetchInterestedConcertListCallCount == 1)
        #expect(repository.fetchInterestedConcertListFilter?.sort == .ticketing)
        #expect(repository.fetchInterestedConcertListFilter?.limit == 12)
        #expect(repository.fetchInterestedConcertListFilter?.position == nil)
        #expect(sut.interestConcertList.map(\.id) == [1, 2])
        #expect(sut.hasMorePages)
        #expect(!sut.isInitialLoading)
        #expect(sut.errorMessage.isEmpty)
    }

    @Test("다음 페이지 요청 시 position으로 조회하고 기존 목록 뒤에 추가해야 한다")
    func 다음_페이지_요청은_position으로_조회하고_기존_목록_뒤에_추가해야_한다() async throws {
        // Given
        let firstPosition = makePosition(id: 2)
        repository.interestConcertListResultQueue = [
            .success(makeListResult(concertIDList: [1, 2], position: firstPosition)),
            .success(makeListResult(concertIDList: [3, 4], position: nil))
        ]
        let sut = InterestConcertListViewModel(repository: repository)
        await sut.loadIfNeeded()

        // When
        await sut.loadNextPage()

        // Then
        #expect(repository.fetchInterestedConcertListCallCount == 2)
        let nextPageFilter = repository.fetchInterestedConcertListFilterList.dropFirst().first
        #expect(nextPageFilter?.position as? TestPosition == firstPosition)
        #expect(nextPageFilter?.limit == 12)
        #expect(sut.interestConcertList.map(\.id) == [1, 2, 3, 4])
        #expect(!sut.hasMorePages)
        #expect(!sut.isLoadingMore)
    }

    @Test("더 이상 페이지가 없거나 로딩 중이면 다음 페이지를 중복 조회하지 않아야 한다")
    func 다음_페이지가_없거나_로딩_중이면_중복_조회하지_않아야_한다() async throws {
        // Given
        repository.interestConcertListResultQueue = [
            .success(makeListResult(concertIDList: [1], position: nil))
        ]
        let sut = InterestConcertListViewModel(repository: repository)
        await sut.loadIfNeeded()

        // When
        await sut.loadNextPage()
        await sut.loadNextPage()

        // Then
        #expect(repository.fetchInterestedConcertListCallCount == 1)
    }

    @Test("초기 로딩 중이면 다음 페이지를 조회하지 않아야 한다")
    func 초기_로딩_중이면_다음_페이지를_조회하지_않아야_한다() async throws {
        // Given
        repository.fetchInterestedConcertListDelayQueue = [200_000_000]
        repository.interestConcertListResultQueue = [
            .success(makeListResult(concertIDList: [1, 2], position: makePosition(id: 2)))
        ]
        let sut = InterestConcertListViewModel(repository: repository)

        // When
        let request = Task { await sut.loadIfNeeded() }
        try await waitUntilFetchInterestedConcertListCallCount(1)
        #expect(sut.isInitialLoading)
        await sut.loadNextPage()
        await request.value

        // Then
        #expect(repository.fetchInterestedConcertListCallCount == 1)
    }

    @Test("호출자가 첫 조회를 취소하면 응답을 버리고 다시 조회할 수 있다")
    func 첫_조회_취소_후_다시_조회한다() async throws {
        repository.fetchInterestedConcertListDelayQueue = [200_000_000, 0]
        repository.interestConcertListResultQueue = [
            .success(makeListResult(concertIDList: [1], position: nil)),
            .success(makeListResult(concertIDList: [2], position: nil))
        ]
        let sut = InterestConcertListViewModel(repository: repository)
        let request = Task { await sut.loadIfNeeded() }
        try await waitUntilFetchInterestedConcertListCallCount(1)

        request.cancel()
        await request.value

        #expect(!sut.isInitialLoading)
        #expect(sut.interestConcertList.isEmpty)
        #expect(sut.errorMessage.isEmpty)
        await sut.loadIfNeeded()
        #expect(sut.interestConcertList.map(\.id) == [2])
    }

    @Test("다음 페이지 로딩 중이면 다음 페이지를 중복 조회하지 않아야 한다")
    func 다음_페이지_로딩_중이면_다음_페이지를_중복_조회하지_않아야_한다() async throws {
        // Given
        repository.interestConcertListResultQueue = [
            .success(makeListResult(concertIDList: [1, 2], position: makePosition(id: 2))),
            .success(makeListResult(concertIDList: [3, 4], position: makePosition(id: 4)))
        ]
        repository.fetchInterestedConcertListDelayQueue = [0, 200_000_000]
        let sut = InterestConcertListViewModel(repository: repository)
        await sut.loadIfNeeded()

        // When
        let request = Task { await sut.loadNextPage() }
        try await waitUntilFetchInterestedConcertListCallCount(2)
        #expect(sut.isLoadingMore)
        await sut.loadNextPage()
        await request.value

        // Then
        #expect(repository.fetchInterestedConcertListCallCount == 2)
    }

    @Test("정렬 변경 성공 시 목록과 다음 페이지 여부를 새 정렬 결과로 교체해야 한다")
    func 정렬_변경_성공은_목록과_다음_페이지_여부를_새_정렬_결과로_교체해야_한다() async throws {
        // Given
        let ticketingPosition = makePosition(id: 2)
        let concertPosition = makePosition(id: 12)
        repository.interestConcertListResultQueue = [
            .success(makeListResult(concertIDList: [1, 2], position: ticketingPosition)),
            .success(makeListResult(concertIDList: [11, 12], position: concertPosition))
        ]
        let sut = InterestConcertListViewModel(repository: repository)
        await sut.loadIfNeeded()

        // When
        repository.fetchInterestedConcertListDelayQueue = [200_000_000]
        let request = Task { await sut.selectSort(.concert) }
        try await waitUntilFetchInterestedConcertListCallCount(2)

        #expect(sut.selectedSort == .concert)
        #expect(sut.interestConcertList.isEmpty)
        #expect(sut.hasMorePages)
        #expect(sut.isInitialLoading)
        await request.value


        // Then
        #expect(repository.fetchInterestedConcertListCallCount == 2)
        let sortFilter = repository.fetchInterestedConcertListFilterList.dropFirst().first
        #expect(sortFilter?.sort == .concert)
        #expect(sortFilter?.position == nil)
        #expect(sut.selectedSort == .concert)
        #expect(sut.interestConcertList.map(\.id) == [11, 12])
        #expect(sut.hasMorePages)
        #expect(sut.errorMessage.isEmpty)
    }

    @Test("정렬 변경 실패 시 기존 목록과 정렬과 다음 페이지 여부를 유지하고 오류 메시지만 설정해야 한다")
    func 정렬_변경_실패는_기존_목록과_정렬과_다음_페이지_여부를_유지하고_오류_메시지만_설정해야_한다() async throws {
        // Given
        repository.interestConcertListResultQueue = [
            .success(makeListResult(concertIDList: [1, 2], position: makePosition(id: 2))),
            .failure(.serverError)
        ]
        let sut = InterestConcertListViewModel(repository: repository)
        await sut.loadIfNeeded()

        // When
        await sut.selectSort(.concert)

        // Then
        #expect(sut.selectedSort == .ticketing)
        #expect(sut.interestConcertList.map(\.id) == [1, 2])
        #expect(sut.hasMorePages)
        #expect(!sut.errorMessage.isEmpty)
    }

    @Test("정렬 변경 응답 이후 이전 다음 페이지 응답이 도착해도 새 정렬 목록에 섞지 않아야 한다")
    func 정렬_변경_이후_이전_다음_페이지_응답은_무시해야_한다() async throws {
        // Given
        repository.interestConcertListResultQueue = [
            .success(makeListResult(concertIDList: [1, 2], position: makePosition(id: 2))),
            .success(makeListResult(concertIDList: [3, 4], position: nil)),
            .success(makeListResult(concertIDList: [11, 12], position: nil))
        ]
        repository.fetchInterestedConcertListDelayQueue = [0, 200_000_000, 0]
        let sut = InterestConcertListViewModel(repository: repository)
        await sut.loadIfNeeded()

        // When
        let previousPage = Task { await sut.loadNextPage() }
        try await waitUntilFetchInterestedConcertListCallCount(2)
        await sut.selectSort(.concert)

        await previousPage.value
        // Then
        #expect(sut.selectedSort == .concert)
        #expect(sut.interestConcertList.map(\.id) == [11, 12])
        #expect(!sut.hasMorePages)
    }

    @Test("다음 페이지 로딩 중 정렬 변경이 실패하면 이전 커서로 다시 조회할 수 있다")
    func 정렬_실패_후_이전_커서로_다음_페이지를_재시도한다() async throws {
        let cursor = makePosition(id: 2)
        repository.interestConcertListResultQueue = [
            .success(makeListResult(concertIDList: [1, 2], position: cursor)),
            .success(makeListResult(concertIDList: [3], position: nil)),
            .failure(.serverError),
            .success(makeListResult(concertIDList: [4], position: nil))
        ]
        repository.fetchInterestedConcertListDelayQueue = [0, 200_000_000, 0, 0]
        let sut = InterestConcertListViewModel(repository: repository)
        await sut.loadIfNeeded()
        let previousPage = Task { await sut.loadNextPage() }
        try await waitUntilFetchInterestedConcertListCallCount(2)

        await sut.selectSort(.concert)
        await previousPage.value
        #expect(sut.selectedSort == .ticketing)
        #expect(!sut.isLoadingMore)
        await sut.loadNextPage()

        #expect(repository.fetchInterestedConcertListCallCount == 4)
        #expect(repository.fetchInterestedConcertListFilter?.position as? TestPosition == cursor)
        #expect(sut.interestConcertList.map(\.id) == [1, 2, 4])
    }

    @Test("최초 조회 실패 시 목록은 비어 있고 오류 메시지를 설정해야 한다")
    func 최초_조회_실패는_목록을_비우고_오류_메시지를_설정해야_한다() async throws {
        // Given
        repository.interestConcertListResultQueue = [.failure(.serverError)]
        let sut = InterestConcertListViewModel(repository: repository)

        // When
        await sut.loadIfNeeded()

        // Then
        #expect(sut.interestConcertList.isEmpty)
        #expect(!sut.hasMorePages)
        #expect(!sut.isInitialLoading)
        #expect(!sut.errorMessage.isEmpty)
    }

    @Test("다음 페이지 조회 실패 시 기존 목록과 다음 페이지 여부를 유지하고 오류 메시지를 설정해야 한다")
    func 다음_페이지_조회_실패는_기존_목록과_다음_페이지_여부를_유지하고_오류_메시지를_설정해야_한다() async throws {
        // Given
        repository.interestConcertListResultQueue = [
            .success(makeListResult(concertIDList: [1, 2], position: makePosition(id: 2))),
            .failure(.serverError)
        ]
        let sut = InterestConcertListViewModel(repository: repository)
        await sut.loadIfNeeded()

        // When
        await sut.loadNextPage()

        // Then
        #expect(sut.interestConcertList.map(\.id) == [1, 2])
        #expect(sut.hasMorePages)
        #expect(!sut.isLoadingMore)
        #expect(!sut.errorMessage.isEmpty)
    }

    @Test("조회 성공 시 이전 오류 메시지를 비워야 한다")
    func 조회_성공은_이전_오류_메시지를_비워야_한다() async throws {
        // Given
        let position = makePosition(id: 2)
        repository.interestConcertListResultQueue = [
            .failure(.serverError),
            .success(makeListResult(concertIDList: [1, 2], position: position))
        ]
        let sut = InterestConcertListViewModel(repository: repository)
        await sut.loadIfNeeded()
        #expect(!sut.errorMessage.isEmpty)

        // When
        await sut.loadIfNeeded()

        // Then
        #expect(sut.errorMessage.isEmpty)
        #expect(sut.interestConcertList.map(\.id) == [1, 2])
    }
}

// MARK: - Helpers

private extension InterestConcertListViewModelTests {
    func waitUntilFetchInterestedConcertListCallCount(_ expectedCount: Int) async throws {
        let deadline = ContinuousClock.now + .seconds(5)
        while repository.fetchInterestedConcertListCallCount < expectedCount, ContinuousClock.now < deadline {
            try await Task.sleep(for: .milliseconds(5))
        }
        try #require(repository.fetchInterestedConcertListCallCount >= expectedCount)
    }

    func makeListResult(
        concertIDList: [Int],
        position: TestPosition?
    ) -> ListResult<InterestConcert> {
        ListResult(
            items: makeInterestConcertList(concertIDList: concertIDList),
            position: position
        )
    }

    func makeInterestConcertList(concertIDList: [Int]) -> [InterestConcert] {
        concertIDList.map { concertID in
            InterestConcert(
                concert: makeConcert(id: concertID),
                ticketingSchedule: InterestConcertTicketingSchedule(preSaleDate: nil, generalSaleDate: nil)
            )
        }
    }

    func makeConcert(id: Int) -> Concert {
        Concert(
            id: id,
            title: "테스트 콘서트 \(id)",
            artist: "테스트 아티스트",
            status: .upcoming,
            daysLeft: 10,
            startDate: Date(timeIntervalSince1970: 1_783_584_000),
            endDate: Date(timeIntervalSince1970: 1_783_670_400),
            posterURL: URL(string: "https://example.com/poster\(id).jpg"),
            venue: "테스트 공연장",
            ticketSite: "인터파크",
            ticketURL: URL(string: "https://ticket.example.com"),
            introduction: "테스트 소개",
            label: nil
        )
    }

    func makePosition(id: Int) -> TestPosition {
        TestPosition(
            date: Date(timeIntervalSince1970: TimeInterval(1_783_584_000 + id)),
            id: id
        )
    }
}

private struct TestPosition: PagePosition, Equatable {
    let date: Date
    let id: Int
}
