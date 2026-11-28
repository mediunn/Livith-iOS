//
//  ConcertRequestStoreTests.swift
//  ShareFeatureTests
//
//  Created by Youjin Lee on 7/24/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Testing

import Domain
@testable import ShareFeature

@MainActor
struct ConcertRequestViewModelTests {
    let repository = MockConcertRequestRepository()

    @Test("요청 성공 시 정규화한 초안을 전달하고 성공 상태로 전이한다")
    func 요청_성공_시_정규화한_초안을_전달한다() async {
        let sut = ConcertRequestViewModel(repository: repository)
        sut.concertName = " 테일러 스위프트 콘서트 "
        sut.urlText = " https://www.example.com/concert/1 "
        sut.additionalNote = " 아티스트명: 테일러 스위프트 "

        await sut.submit(shouldAutoRegister: true)

        #expect(repository.requestConcertCallCount == 1)
        #expect(repository.requestConcertTitle == "테일러 스위프트 콘서트")
        #expect(repository.requestConcertURL == "https://www.example.com/concert/1")
        #expect(repository.requestConcertAutoRegister == true)
        #expect(repository.requestConcertContent == "아티스트명: 테일러 스위프트")
        #expect(sut.submission == .succeeded)
    }

    @Test("선택 입력이 비어 있으면 nil로 전달한다")
    func 선택_입력이_비어_있으면_nil로_전달한다() async {
        let sut = ConcertRequestViewModel(
            repository: repository,
            concertName: "공연",
            urlText: " ",
            additionalNote: ""
        )

        await sut.submit(shouldAutoRegister: false)

        #expect(repository.requestConcertCallCount == 1)
        #expect(repository.requestConcertURL == nil)
        #expect(repository.requestConcertAutoRegister == false)
        #expect(repository.requestConcertContent == nil)
    }

    @Test("요청 실패 시 초안을 보존하고 실패 상태로 전이한다")
    func 요청_실패_시_초안을_보존한다() async {
        repository.requestConcertErrorStub = .serverError
        let sut = ConcertRequestViewModel(repository: repository, concertName: "공연")

        await sut.submit(shouldAutoRegister: true)

        #expect(repository.requestConcertCallCount == 1)
        #expect(sut.submission == .failed)
        #expect(sut.concertName == "공연")
    }

    @Test("제출 중 들어온 중복 호출은 같은 공연을 다시 요청하지 않는다")
    func 제출_중에는_중복_제출을_무시한다() async {
        let sut = ConcertRequestViewModel(repository: repository, concertName: "공연")
        repository.onRequest = {
            #expect(sut.submission == .submitting)
            await sut.submit(shouldAutoRegister: false)
        }

        await sut.submit(shouldAutoRegister: true)

        #expect(repository.requestConcertCallCount == 1)
        #expect(repository.requestConcertAutoRegister == true)
        #expect(sut.submission == .succeeded)
    }

    @Test("실패 토스트를 닫으면 상태를 초기화하고 같은 초안을 다시 제출할 수 있다")
    func 실패_토스트를_닫으면_같은_초안으로_재시도한다() async {
        repository.requestConcertErrorStub = .serverError
        let sut = ConcertRequestViewModel(repository: repository, concertName: "공연")
        await sut.submit(shouldAutoRegister: true)
        #expect(sut.submission == .failed)

        sut.dismissFailure()

        #expect(sut.submission == .idle)
        repository.requestConcertErrorStub = nil
        await sut.submit(shouldAutoRegister: true)
        #expect(repository.requestConcertCallCount == 2)
        #expect(repository.requestConcertTitle == "공연")
        #expect(sut.submission == .succeeded)
    }
}
