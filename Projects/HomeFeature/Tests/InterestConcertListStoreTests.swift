//
//  InterestConcertListStoreTests.swift
//  HomeFeatureTests
//
//  Created by 김진웅 on 5/1/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

import Testing

@testable import HomeFeature
import DIContainer
import Domain

@MainActor
struct InterestConcertListStoreTests {

    // MARK: - Properties

    let container: MockDIContainer

    // MARK: - Initializer

    init() {
        self.container = MockDIContainer()
        self.container.registerDependencies()
    }

    // MARK: - Tests

    @Test("onAppear 시 첫 페이지를 기본 정렬과 12개 페이지 크기로 조회해야 한다")
    func onAppear는_첫_페이지를_기본_정렬과_12개_페이지_크기로_조회해야_한다() async throws {
        // Given
        let nextToken = makeToken(id: 2)
        container.userRepository.interestConcertListResultQueue = [
            .success(makeListResult(concertIDList: [1, 2], nextToken: nextToken))
        ]
        let sut = InterestConcertListStore()

        // When
        sut.send(.onAppear)
        try await waitForAsyncTask()

        // Then
        #expect(container.userRepository.fetchInterestedConcertListCallCount == 1)
        #expect(container.userRepository.fetchInterestedConcertListFilter?.sort == .concert)
        #expect(container.userRepository.fetchInterestedConcertListFilter?.limit == 12)
        #expect(container.userRepository.fetchInterestedConcertListFilter?.nextToken == nil)
        #expect(sut.state.interestConcertList.map(\.id) == [1, 2])
        #expect(sut.state.hasMorePages)
        #expect(!sut.state.isInitialLoading)
        #expect(sut.state.errorMessage.isEmpty)
    }

    @Test("다음 페이지 요청 시 nextToken으로 조회하고 기존 목록 뒤에 추가해야 한다")
    func 다음_페이지_요청은_nextToken으로_조회하고_기존_목록_뒤에_추가해야_한다() async throws {
        // Given
        let firstToken = makeToken(id: 2)
        container.userRepository.interestConcertListResultQueue = [
            .success(makeListResult(concertIDList: [1, 2], nextToken: firstToken)),
            .success(makeListResult(concertIDList: [3, 4], nextToken: nil))
        ]
        let sut = InterestConcertListStore()
        sut.send(.onAppear)
        try await waitForAsyncTask()

        // When
        sut.send(.loadNextPage)
        try await waitForAsyncTask()

        // Then
        #expect(container.userRepository.fetchInterestedConcertListCallCount == 2)
        let nextPageFilter = container.userRepository.fetchInterestedConcertListFilterList.dropFirst().first
        #expect(nextPageFilter?.nextToken as? TestNextToken == firstToken)
        #expect(nextPageFilter?.limit == 12)
        #expect(sut.state.interestConcertList.map(\.id) == [1, 2, 3, 4])
        #expect(!sut.state.hasMorePages)
        #expect(!sut.state.isLoadingMore)
    }

    @Test("더 이상 페이지가 없거나 로딩 중이면 다음 페이지를 중복 조회하지 않아야 한다")
    func 다음_페이지가_없거나_로딩_중이면_중복_조회하지_않아야_한다() async throws {
        // Given
        container.userRepository.interestConcertListResultQueue = [
            .success(makeListResult(concertIDList: [1], nextToken: nil))
        ]
        let sut = InterestConcertListStore()
        sut.send(.onAppear)
        try await waitForAsyncTask()

        // When
        sut.send(.loadNextPage)
        sut.send(.loadNextPage)
        try await waitForAsyncTask()

        // Then
        #expect(container.userRepository.fetchInterestedConcertListCallCount == 1)
    }

    @Test("초기 로딩 중이면 다음 페이지를 조회하지 않아야 한다")
    func 초기_로딩_중이면_다음_페이지를_조회하지_않아야_한다() async throws {
        // Given
        container.userRepository.fetchInterestedConcertListDelayQueue = [200_000_000]
        container.userRepository.interestConcertListResultQueue = [
            .success(makeListResult(concertIDList: [1, 2], nextToken: makeToken(id: 2)))
        ]
        let sut = InterestConcertListStore()

        // When
        sut.send(.onAppear)
        #expect(sut.state.isInitialLoading)
        sut.send(.loadNextPage)
        try await Task.sleep(nanoseconds: 250_000_000)

        // Then
        #expect(container.userRepository.fetchInterestedConcertListCallCount == 1)
    }

    @Test("다음 페이지 로딩 중이면 다음 페이지를 중복 조회하지 않아야 한다")
    func 다음_페이지_로딩_중이면_다음_페이지를_중복_조회하지_않아야_한다() async throws {
        // Given
        container.userRepository.interestConcertListResultQueue = [
            .success(makeListResult(concertIDList: [1, 2], nextToken: makeToken(id: 2))),
            .success(makeListResult(concertIDList: [3, 4], nextToken: makeToken(id: 4)))
        ]
        container.userRepository.fetchInterestedConcertListDelayQueue = [0, 200_000_000]
        let sut = InterestConcertListStore()
        sut.send(.onAppear)
        try await waitForAsyncTask()

        // When
        sut.send(.loadNextPage)
        #expect(sut.state.isLoadingMore)
        sut.send(.loadNextPage)
        try await Task.sleep(nanoseconds: 250_000_000)

        // Then
        #expect(container.userRepository.fetchInterestedConcertListCallCount == 2)
    }

    @Test("정렬 변경 성공 시 목록과 다음 페이지 여부를 새 정렬 결과로 교체해야 한다")
    func 정렬_변경_성공은_목록과_다음_페이지_여부를_새_정렬_결과로_교체해야_한다() async throws {
        // Given
        let concertToken = makeToken(id: 2)
        let ticketingToken = makeToken(id: 12)
        container.userRepository.interestConcertListResultQueue = [
            .success(makeListResult(concertIDList: [1, 2], nextToken: concertToken)),
            .success(makeListResult(concertIDList: [11, 12], nextToken: ticketingToken))
        ]
        let sut = InterestConcertListStore()
        sut.send(.onAppear)
        try await waitForAsyncTask()

        // When
        sut.send(.sortSelected(.ticketing))

        #expect(sut.state.selectedSort == .ticketing)
        #expect(sut.state.interestConcertList.isEmpty)
        #expect(sut.state.hasMorePages)
        #expect(sut.state.isInitialLoading)

        try await waitForAsyncTask()

        // Then
        #expect(container.userRepository.fetchInterestedConcertListCallCount == 2)
        let sortFilter = container.userRepository.fetchInterestedConcertListFilterList.dropFirst().first
        #expect(sortFilter?.sort == .ticketing)
        #expect(sortFilter?.nextToken == nil)
        #expect(sut.state.selectedSort == .ticketing)
        #expect(sut.state.interestConcertList.map(\.id) == [11, 12])
        #expect(sut.state.hasMorePages)
        #expect(sut.state.errorMessage.isEmpty)
    }

    @Test("정렬 변경 실패 시 기존 목록과 정렬과 다음 페이지 여부를 유지하고 오류 메시지만 설정해야 한다")
    func 정렬_변경_실패는_기존_목록과_정렬과_다음_페이지_여부를_유지하고_오류_메시지만_설정해야_한다() async throws {
        // Given
        container.userRepository.interestConcertListResultQueue = [
            .success(makeListResult(concertIDList: [1, 2], nextToken: makeToken(id: 2))),
            .failure(.serverError)
        ]
        let sut = InterestConcertListStore()
        sut.send(.onAppear)
        try await waitForAsyncTask()

        // When
        sut.send(.sortSelected(.ticketing))
        try await waitForAsyncTask()

        // Then
        #expect(sut.state.selectedSort == .concert)
        #expect(sut.state.interestConcertList.map(\.id) == [1, 2])
        #expect(sut.state.hasMorePages)
        #expect(!sut.state.errorMessage.isEmpty)
    }

    @Test("정렬 변경 응답 이후 이전 다음 페이지 응답이 도착해도 새 정렬 목록에 섞지 않아야 한다")
    func 정렬_변경_이후_이전_다음_페이지_응답은_무시해야_한다() async throws {
        // Given
        container.userRepository.interestConcertListResultQueue = [
            .success(makeListResult(concertIDList: [1, 2], nextToken: makeToken(id: 2))),
            .success(makeListResult(concertIDList: [3, 4], nextToken: nil)),
            .success(makeListResult(concertIDList: [11, 12], nextToken: nil))
        ]
        container.userRepository.fetchInterestedConcertListDelayQueue = [0, 200_000_000, 0]
        let sut = InterestConcertListStore()
        sut.send(.onAppear)
        try await waitForAsyncTask()

        // When
        sut.send(.loadNextPage)
        await Task.yield()
        sut.send(.sortSelected(.ticketing))
        try await Task.sleep(nanoseconds: 300_000_000)

        // Then
        #expect(sut.state.selectedSort == .ticketing)
        #expect(sut.state.interestConcertList.map(\.id) == [11, 12])
        #expect(!sut.state.hasMorePages)
    }

    @Test("최초 조회 실패 시 목록은 비어 있고 오류 메시지를 설정해야 한다")
    func 최초_조회_실패는_목록을_비우고_오류_메시지를_설정해야_한다() async throws {
        // Given
        container.userRepository.interestConcertListResultQueue = [.failure(.serverError)]
        let sut = InterestConcertListStore()

        // When
        sut.send(.onAppear)
        try await waitForAsyncTask()

        // Then
        #expect(sut.state.interestConcertList.isEmpty)
        #expect(!sut.state.hasMorePages)
        #expect(!sut.state.isInitialLoading)
        #expect(!sut.state.errorMessage.isEmpty)
    }

    @Test("다음 페이지 조회 실패 시 기존 목록과 다음 페이지 여부를 유지하고 오류 메시지를 설정해야 한다")
    func 다음_페이지_조회_실패는_기존_목록과_다음_페이지_여부를_유지하고_오류_메시지를_설정해야_한다() async throws {
        // Given
        container.userRepository.interestConcertListResultQueue = [
            .success(makeListResult(concertIDList: [1, 2], nextToken: makeToken(id: 2))),
            .failure(.serverError)
        ]
        let sut = InterestConcertListStore()
        sut.send(.onAppear)
        try await waitForAsyncTask()

        // When
        sut.send(.loadNextPage)
        try await waitForAsyncTask()

        // Then
        #expect(sut.state.interestConcertList.map(\.id) == [1, 2])
        #expect(sut.state.hasMorePages)
        #expect(!sut.state.isLoadingMore)
        #expect(!sut.state.errorMessage.isEmpty)
    }

    @Test("조회 성공 시 이전 오류 메시지를 비워야 한다")
    func 조회_성공은_이전_오류_메시지를_비워야_한다() async throws {
        // Given
        let nextToken = makeToken(id: 2)
        container.userRepository.interestConcertListResultQueue = [
            .failure(.serverError),
            .success(makeListResult(concertIDList: [1, 2], nextToken: nextToken))
        ]
        let sut = InterestConcertListStore()
        sut.send(.onAppear)
        try await waitForAsyncTask()
        #expect(!sut.state.errorMessage.isEmpty)

        // When
        sut.send(.onAppear)
        try await waitForAsyncTask()

        // Then
        #expect(sut.state.errorMessage.isEmpty)
        #expect(sut.state.interestConcertList.map(\.id) == [1, 2])
    }
}

// MARK: - Helpers

private extension InterestConcertListStoreTests {
    func waitForAsyncTask() async throws {
        try await Task.sleep(nanoseconds: 100_000_000)
    }

    func makeListResult(
        concertIDList: [Int],
        nextToken: TestNextToken?
    ) -> ListResult<InterestConcert> {
        ListResult(
            items: makeInterestConcertList(concertIDList: concertIDList),
            nextToken: nextToken
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

    func makeToken(id: Int) -> TestNextToken {
        TestNextToken(
            date: Date(timeIntervalSince1970: TimeInterval(1_783_584_000 + id)),
            id: id
        )
    }
}

private struct TestNextToken: NextToken, Equatable {
    let date: Date
    let id: Int
}
