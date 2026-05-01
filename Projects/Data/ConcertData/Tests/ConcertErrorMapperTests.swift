//
//  ConcertErrorMapperTests.swift
//  ConcertDataTests
//
//  Created by 김진웅 on 5/1/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation
import Testing

import Domain
import LivithNetwork
@testable import ConcertData

struct ConcertErrorMapperTests {
    @Test("요청 생성 관련 에러를 invalidRequest로 변환해야 한다")
    func 요청_생성_관련_에러를_invalidRequest로_변환해야_한다() {
        // Given
        let sut = ConcertErrorMapper()
        let errorList: [NetworkError] = [
            .invalidURL,
            .invalidRequest
        ]

        for error in errorList {
            // When
            let result = sut.mapToConcertError(error)

            // Then
            #expect(result == .invalidRequest)
        }
    }

    @Test("응답 관련 에러를 invalidResponse로 변환해야 한다")
    func 응답_관련_에러를_invalidResponse로_변환해야_한다() {
        // Given
        let sut = ConcertErrorMapper()
        let errorList: [NetworkError] = [
            .decodingFailed(NSError(domain: "", code: -1)),
            .invalidResponse,
            .badRequest(message: nil),
            .clientError(statusCode: 400, message: nil)
        ]

        for error in errorList {
            // When
            let result = sut.mapToConcertError(error)

            // Then
            #expect(result == .invalidResponse)
        }
    }
}
