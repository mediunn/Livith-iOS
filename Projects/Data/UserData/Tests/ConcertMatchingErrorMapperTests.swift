//
//  ConcertMatchingErrorMapperTests.swift
//  UserDataTests
//
//  Created by youz2me on 7/20/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation
import Testing

import Domain
import LivithNetworking
@testable import UserData

@Suite("콘서트 매칭 에러 매퍼 테스트")
struct ConcertMatchingErrorMapperTests {
    @Test("연결 없음 에러는 noConnection으로 매핑되어야 한다")
    func 연결_없음_에러는_noConnection으로_매핑되어야_한다() {
        let sut = ConcertMatchingErrorMapper()

        let result = sut.mapToConcertMatchingError(
            NetworkError.noConnection(URLError(.notConnectedToInternet))
        )

        #expect(result == .noConnection)
    }

    @Test("타임아웃 에러는 noConnection으로 매핑되어야 한다")
    func 타임아웃_에러는_noConnection으로_매핑되어야_한다() {
        let sut = ConcertMatchingErrorMapper()

        let result = sut.mapToConcertMatchingError(NetworkError.timeout(URLError(.timedOut)))

        #expect(result == .noConnection)
    }

    @Test("취소 에러는 cancelled로 매핑되어야 한다")
    func 취소_에러는_cancelled로_매핑되어야_한다() {
        let sut = ConcertMatchingErrorMapper()

        let result = sut.mapToConcertMatchingError(CancellationError())

        #expect(result == .cancelled)
    }

    @Test("서버 에러는 serverError로 매핑되어야 한다")
    func 서버_에러는_serverError로_매핑되어야_한다() {
        let sut = ConcertMatchingErrorMapper()

        let result = sut.mapToConcertMatchingError(
            NetworkError.serverError(statusCode: 500, message: nil)
        )

        #expect(result == .serverError)
    }

    @Test("잘못된 요청 에러는 matchFailed로 매핑되어야 한다")
    func 잘못된_요청_에러는_matchFailed로_매핑되어야_한다() {
        let sut = ConcertMatchingErrorMapper()

        let result = sut.mapToConcertMatchingError(
            NetworkError.badRequest(message: "유효한 인스타그램 게시글 URL이 아닙니다.")
        )

        #expect(result == .matchFailed)
    }

    @Test("찾을 수 없음 에러는 matchFailed로 매핑되어야 한다")
    func 찾을_수_없음_에러는_matchFailed로_매핑되어야_한다() {
        let sut = ConcertMatchingErrorMapper()

        let result = sut.mapToConcertMatchingError(
            NetworkError.notFound(message: "추출 작업을 찾을 수 없습니다.")
        )

        #expect(result == .matchFailed)
    }

    @Test("디코딩 실패 에러는 invalidResponse로 매핑되어야 한다")
    func 디코딩_실패_에러는_invalidResponse로_매핑되어야_한다() {
        let sut = ConcertMatchingErrorMapper()

        let result = sut.mapToConcertMatchingError(
            NetworkError.decodingFailed(URLError(.cannotParseResponse))
        )

        #expect(result == .invalidResponse)
    }
}
