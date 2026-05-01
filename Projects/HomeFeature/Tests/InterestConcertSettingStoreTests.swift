//
//  InterestConcertSettingStoreTests.swift
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
struct InterestConcertSettingStoreTests {

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
        let sut = InterestConcertSettingStore(mode: .initialSetup)
        try await waitForAsyncTask()

        // Then
        #expect(container.concertRepository.fetchAllConcertListCallCount == 1)
        #expect(container.concertRepository.fetchAllConcertListNextTokenList.first == nil)
        #expect(container.concertRepository.fetchAllConcertListSizeList.first == 12)
        #expect(sut.state.filteredConcertList.map(\.id) == [1, 2])
        #expect(sut.state.hasMoreConcertList)
        #expect(!sut.state.isInitialLoading)
    }

    @Test("다음 페이지 조회 시 nextToken을 그대로 넘기고 목록 뒤에 추가해야 한다")
    func 다음_페이지_조회_시_nextToken을_그대로_넘기고_목록_뒤에_추가해야_한다() async throws {
        // Given
        let nextToken = TestNextToken()
        container.concertRepository.concertListResultQueue = [
            .success(ListResult(items: makeConcertList([1, 2]), nextToken: nextToken)),
            .success(ListResult(items: makeConcertList([3]), nextToken: nil))
        ]
        let sut = InterestConcertSettingStore(mode: .initialSetup)
        try await waitForAsyncTask()

        // When
        sut.send(.loadNextPage)
        try await waitForAsyncTask()

        // Then
        #expect(container.concertRepository.fetchAllConcertListCallCount == 2)
        #expect(container.concertRepository.fetchAllConcertListNextTokenList.dropFirst().first != nil)
        #expect(sut.state.filteredConcertList.map(\.id) == [1, 2, 3])
        #expect(!sut.state.hasMoreConcertList)
        #expect(!sut.state.isLoadingMore)
    }

    @Test("update 모드는 기존 관심 콘서트를 초기 선택값으로 사용해야 한다")
    func update_모드는_기존_관심_콘서트를_초기_선택값으로_사용해야_한다() async throws {
        // Given
        container.concertRepository.concertListResultQueue = [
            .success(ListResult(items: makeConcertList([1, 2]), nextToken: nil))
        ]
        let userInterestConcertList = makeConcertList([2, 4])

        // When
        let sut = InterestConcertSettingStore(
            mode: .update,
            userInterestConcertList: userInterestConcertList
        )
        try await waitForAsyncTask()

        // Then
        #expect(sut.state.selectedConcertIDList == [2, 4])
        #expect(sut.state.selectedConcertList.map(\.id) == [2, 4])
        #expect(!sut.state.isCTAEnabled)
    }

    @Test("제출 시 선택한 콘서트 ID 목록으로 관심 콘서트 설정 API를 호출해야 한다")
    func 제출_시_선택한_콘서트_ID_목록으로_관심_콘서트_설정_API를_호출해야_한다() async throws {
        // Given
        container.concertRepository.concertListResultQueue = [
            .success(ListResult(items: makeConcertList([1, 2]), nextToken: nil))
        ]
        container.userRepository.updatedConcertListStub = makeConcertList([1, 2])
        let sut = InterestConcertSettingStore(mode: .initialSetup)
        try await waitForAsyncTask()
        sut.send(.toggleConcertSelection(1))
        sut.send(.toggleConcertSelection(2))

        // When
        sut.send(.submit)
        try await waitForAsyncTask()

        // Then
        #expect(container.userRepository.updateInterestedConcertListCallCount == 1)
        #expect(container.userRepository.updateInterestedConcertIDList == [1, 2])
        #expect(sut.state.successMessage == "관심 콘서트를 설정했어요")
        #expect(!sut.state.isSubmitting)
    }

    @Test("제출 실패 시 errorMessage를 설정하고 제출 로딩을 종료해야 한다")
    func 제출_실패_시_errorMessage를_설정하고_제출_로딩을_종료해야_한다() async throws {
        // Given
        container.concertRepository.concertListResultQueue = [
            .success(ListResult(items: makeConcertList([1]), nextToken: nil))
        ]
        container.userRepository.errorStub = .serverError
        let sut = InterestConcertSettingStore(mode: .initialSetup)
        try await waitForAsyncTask()
        sut.send(.toggleConcertSelection(1))

        // When
        sut.send(.submit)
        try await waitForAsyncTask()

        // Then
        #expect(container.userRepository.updateInterestedConcertListCallCount == 1)
        #expect(!sut.state.errorMessage.isEmpty)
        #expect(!sut.state.isSubmitting)
    }
}

// MARK: - Helpers

private extension InterestConcertSettingStoreTests {
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
}

private struct TestNextToken: NextToken {}
