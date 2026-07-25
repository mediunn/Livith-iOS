//
//  ConcertRequestStoreTests.swift
//  ShareFeatureTests
//
//  Created by Youjin Lee on 7/24/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

import Testing

@testable import ShareFeature
import DIContainer
import Domain

@MainActor
struct ConcertRequestStoreTests {

    // MARK: - Properties

    let container: MockDIContainer

    // MARK: - Initializer

    init() {
        self.container = MockDIContainer()
        self.container.registerDependencies()
    }

    // MARK: - Tests

    @Test("요청 성공 시 입력값을 전달하고 성공 상태로 전이해야 한다")
    func 요청_성공_시_입력값을_전달하고_성공_상태로_전이해야_한다() async throws {
        // Given
        let sut = ConcertRequestStore()

        // When
        sut.send(.submit(
            title: "테일러 스위프트 콘서트",
            url: "https://www.example.com/concert/1",
            shouldAutoRegister: true,
            requestContent: "아티스트명: 테일러 스위프트"
        ))
        try await waitForAsyncTask()

        // Then
        #expect(container.concertRepository.requestConcertCallCount == 1)
        #expect(container.concertRepository.requestConcertTitle == "테일러 스위프트 콘서트")
        #expect(container.concertRepository.requestConcertURL == "https://www.example.com/concert/1")
        #expect(container.concertRepository.requestConcertAutoRegister == true)
        #expect(container.concertRepository.requestConcertContent == "아티스트명: 테일러 스위프트")
        #expect(sut.state.didSubmitSucceed)
        #expect(!sut.state.isSubmitting)
        #expect(!sut.state.showFailureToast)
    }

    @Test("선택 입력이 비어 있으면 nil로 전달해야 한다")
    func 선택_입력이_비어_있으면_nil로_전달해야_한다() async throws {
        // Given
        let sut = ConcertRequestStore()

        // When
        sut.send(.submit(title: "공연", url: nil, shouldAutoRegister: false, requestContent: nil))
        try await waitForAsyncTask()

        // Then
        #expect(container.concertRepository.requestConcertURL == nil)
        #expect(container.concertRepository.requestConcertAutoRegister == false)
        #expect(container.concertRepository.requestConcertContent == nil)
    }

    @Test("요청 실패 시 실패 토스트를 표시하고 성공 상태로 전이하지 않아야 한다")
    func 요청_실패_시_실패_토스트를_표시하고_성공_상태로_전이하지_않아야_한다() async throws {
        // Given
        container.concertRepository.requestConcertErrorStub = .serverError
        let sut = ConcertRequestStore()

        // When
        sut.send(.submit(title: "공연", url: nil, shouldAutoRegister: true, requestContent: nil))
        try await waitForAsyncTask()

        // Then
        #expect(container.concertRepository.requestConcertCallCount == 1)
        #expect(!sut.state.didSubmitSucceed)
        #expect(!sut.state.isSubmitting)
        #expect(sut.state.showFailureToast)
    }

    @Test("제출 중에는 중복 제출을 무시해야 한다")
    func 제출_중에는_중복_제출을_무시해야_한다() async throws {
        // Given
        container.concertRepository.requestConcertDelay = 200_000_000
        let sut = ConcertRequestStore()

        // When
        sut.send(.submit(title: "공연", url: nil, shouldAutoRegister: true, requestContent: nil))
        sut.send(.submit(title: "공연", url: nil, shouldAutoRegister: true, requestContent: nil))
        try await Task.sleep(nanoseconds: 400_000_000)

        // Then
        #expect(container.concertRepository.requestConcertCallCount == 1)
    }

    @Test("실패 토스트가 사라지면 토스트 상태를 초기화해야 한다")
    func 실패_토스트가_사라지면_토스트_상태를_초기화해야_한다() async throws {
        // Given
        container.concertRepository.requestConcertErrorStub = .serverError
        let sut = ConcertRequestStore()
        sut.send(.submit(title: "공연", url: nil, shouldAutoRegister: true, requestContent: nil))
        try await waitForAsyncTask()
        #expect(sut.state.showFailureToast)

        // When
        sut.send(.onFailureToastDisappear)

        // Then
        #expect(!sut.state.showFailureToast)
    }
}

// MARK: - Helpers

private extension ConcertRequestStoreTests {
    func waitForAsyncTask() async throws {
        try await Task.sleep(nanoseconds: 100_000_000)
    }
}
