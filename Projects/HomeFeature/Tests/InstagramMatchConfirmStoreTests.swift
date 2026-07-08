//
//  InstagramMatchConfirmStoreTests.swift
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
struct InstagramMatchConfirmStoreTests {

    // MARK: - Properties

    let container: MockDIContainer

    // MARK: - Initializer

    init() {
        self.container = MockDIContainer()
        self.container.registerDependencies()
    }

    // MARK: - Tests

    @Test("초기화 시 매칭 결과를 조회하고 목록을 설정해야 한다")
    func 초기화_시_매칭_결과를_조회하고_목록을_설정해야_한다() async throws {
        // Given
        container.concertMatchingRepository.matchedConcertListResultQueue = [
            .success(makeConcertList([1, 2, 3]))
        ]

        // When
        let sut = InstagramMatchConfirmStore(sourceURL: makeSourceURL())
        try await waitForAsyncTask()

        // Then
        #expect(container.concertMatchingRepository.fetchMatchedConcertListCallCount == 1)
        #expect(container.concertMatchingRepository.fetchMatchedConcertListSourceURLList == [makeSourceURL()])
        #expect(sut.state.matchedConcertList.map(\.id) == [1, 2, 3])
        #expect(!sut.state.isExtracting)
        #expect(!sut.state.shouldNavigateToSearch)
    }

    @Test("매칭 결과가 비어 있으면 검색 화면 이동 상태가 되어야 한다")
    func 매칭_결과가_비어_있으면_검색_화면_이동_상태가_되어야_한다() async throws {
        // Given
        container.concertMatchingRepository.matchedConcertListResultQueue = [
            .success([])
        ]

        // When
        let sut = InstagramMatchConfirmStore(sourceURL: makeSourceURL())
        try await waitForAsyncTask()

        // Then
        #expect(sut.state.shouldNavigateToSearch)
        #expect(!sut.state.isExtracting)
    }

    @Test("매칭 조회 실패 시 검색 화면 이동 상태가 되어야 한다")
    func 매칭_조회_실패_시_검색_화면_이동_상태가_되어야_한다() async throws {
        // Given
        container.concertMatchingRepository.matchedConcertListResultQueue = [
            .failure(.matchFailed)
        ]

        // When
        let sut = InstagramMatchConfirmStore(sourceURL: makeSourceURL())
        try await waitForAsyncTask()

        // Then
        #expect(sut.state.shouldNavigateToSearch)
        #expect(!sut.state.isExtracting)
    }

    @Test("콘서트 선택 시 선택 ID가 바뀌고 등록 버튼이 활성화되어야 한다")
    func 콘서트_선택_시_선택_ID가_바뀌고_등록_버튼이_활성화되어야_한다() async throws {
        // Given
        let sut = try await makeLoadedStore(concertIDList: [1, 2])

        // When
        sut.send(.selectConcert(1))

        // Then
        #expect(sut.state.selectedConcertID == 1)
        #expect(sut.state.isCTAEnabled)

        // When
        sut.send(.selectConcert(2))

        // Then
        #expect(sut.state.selectedConcertID == 2)
    }

    @Test("같은 콘서트를 다시 선택하면 선택이 해제되어야 한다")
    func 같은_콘서트를_다시_선택하면_선택이_해제되어야_한다() async throws {
        // Given
        let sut = try await makeLoadedStore(concertIDList: [1, 2])
        sut.send(.selectConcert(1))
        #expect(sut.state.selectedConcertID == 1)

        // When
        sut.send(.selectConcert(1))

        // Then
        #expect(sut.state.selectedConcertID == nil)
        #expect(!sut.state.isCTAEnabled)
    }

    @Test("등록 성공 시 성공 메시지와 함께 홈 이동 상태가 되어야 한다")
    func 등록_성공_시_성공_메시지와_함께_홈_이동_상태가_되어야_한다() async throws {
        // Given
        container.userRepository.updatedConcertStub = makeConcert(id: 2)
        let sut = try await makeLoadedStore(concertIDList: [1, 2])
        sut.send(.selectConcert(2))

        // When
        sut.send(.register)
        try await waitForAsyncTask()

        // Then
        #expect(container.userRepository.checkInterestedConcertCallCount == 1)
        #expect(container.userRepository.checkInterestedConcertID == 2)
        #expect(container.userRepository.updateInterestedConcertCallCount == 1)
        #expect(sut.state.successMessage == "테스트 콘서트 2 콘서트가\n관심 콘서트와 일정에 자동 등록되었어요")
        #expect(sut.state.shouldNavigateToHome)
        #expect(!sut.state.isRegistering)
    }

    @Test("이미 등록된 콘서트면 등록 요청 없이 성공 처리해야 한다")
    func 이미_등록된_콘서트면_등록_요청_없이_성공_처리해야_한다() async throws {
        // Given
        container.userRepository.checkInterestedConcertResult = true
        let sut = try await makeLoadedStore(concertIDList: [1, 2])
        sut.send(.selectConcert(1))

        // When
        sut.send(.register)
        try await waitForAsyncTask()

        // Then
        #expect(container.userRepository.checkInterestedConcertCallCount == 1)
        #expect(container.userRepository.updateInterestedConcertCallCount == 0)
        #expect(sut.state.successMessage == "테스트 콘서트 1 콘서트가\n관심 콘서트와 일정에 자동 등록되었어요")
        #expect(sut.state.shouldNavigateToHome)
    }

    @Test("콘서트명이 20자를 넘으면 말줄임하여 성공 메시지에 표시해야 한다")
    func 콘서트명이_20자를_넘으면_말줄임하여_성공_메시지에_표시해야_한다() async throws {
        // Given
        let longTitle = "아주아주아주아주아주아주아주아주아주 긴 콘서트 이름"
        container.userRepository.checkInterestedConcertResult = true
        container.concertMatchingRepository.matchedConcertListResultQueue = [
            .success([makeConcert(id: 1, title: longTitle)])
        ]
        let sut = InstagramMatchConfirmStore(sourceURL: makeSourceURL())
        try await waitForAsyncTask()
        sut.send(.selectConcert(1))

        // When
        sut.send(.register)
        try await waitForAsyncTask()

        // Then
        #expect(sut.state.successMessage == "\(longTitle.prefix(20)).. 콘서트가\n관심 콘서트와 일정에 자동 등록되었어요")
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
        #expect(container.userRepository.updateInterestedConcertCallCount == 1)
        #expect(sut.state.errorMessage == "관심 콘서트 등록에 실패했어요\n다시 시도해주세요")
        #expect(!sut.state.shouldNavigateToHome)
        #expect(!sut.state.isRegistering)
    }

    @Test("선택하지 않고 취소하면 홈 이동 상태가 되어야 한다")
    func 선택하지_않고_취소하면_홈_이동_상태가_되어야_한다() async throws {
        // Given
        let sut = try await makeLoadedStore(concertIDList: [1])

        // When
        sut.send(.cancelTapped)

        // Then
        #expect(sut.state.shouldNavigateToHome)
        #expect(!sut.state.isCancelModalPresented)
    }

    @Test("선택한 상태에서 취소하면 중단 팝업이 표시되어야 한다")
    func 선택한_상태에서_취소하면_중단_팝업이_표시되어야_한다() async throws {
        // Given
        let sut = try await makeLoadedStore(concertIDList: [1])
        sut.send(.selectConcert(1))

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
        sut.send(.selectConcert(1))
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
        sut.send(.selectConcert(1))
        sut.send(.cancelTapped)

        // When
        sut.send(.dismissCancelModal)

        // Then
        #expect(!sut.state.isCancelModalPresented)
        #expect(!sut.state.shouldNavigateToHome)
        #expect(sut.state.selectedConcertID == 1)
    }
}

// MARK: - Helpers

private extension InstagramMatchConfirmStoreTests {
    func makeLoadedStore(concertIDList: [Int]) async throws -> InstagramMatchConfirmStore {
        container.concertMatchingRepository.matchedConcertListResultQueue = [
            .success(makeConcertList(concertIDList))
        ]
        let store = InstagramMatchConfirmStore(sourceURL: makeSourceURL())
        try await waitForAsyncTask()
        return store
    }

    func makeSourceURL() -> URL {
        URL(string: "https://www.instagram.com/p/test-post")!
    }

    func makeConcertList(_ idList: [Int]) -> [Concert] {
        idList.map { makeConcert(id: $0) }
    }

    func makeConcert(id: Int, title: String? = nil) -> Concert {
        Concert(
            id: id,
            title: title ?? "테스트 콘서트 \(id)",
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
