//
//  ConcertErrorMapperTests.swift
//  ConcertTests
//
//  Created by Youjin Lee on 12/25/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import Testing
import Foundation

@testable import ConcertData
@testable import ConcertDomain
@testable import LivithNetwork

@Suite("ConcertErrorMapper Tests")
struct ConcertErrorMapperTests {
    let mapper = ConcertErrorMapper()

    // MARK: - NetworkError to ConcertError Mapping

    @Test("noData 에러 매핑")
    func test_에러매핑_noData_notFound반환() {
        // Given
        let networkError = NetworkError.noData

        // When
        let result = mapper.mapToConcertError(networkError)

        // Then
        #expect(result == .notFound)
    }

    @Test("noConnection 에러 매핑")
    func test_에러매핑_noConnection_networkError반환() {
        // Given
        let networkError = NetworkError.noConnection(NSError(domain: "", code: -1))

        // When
        let result = mapper.mapToConcertError(networkError)

        // Then
        #expect(result == .networkError)
    }

    @Test("serverError 에러 매핑")
    func test_에러매핑_serverError_serverError반환() {
        // Given
        let networkError = NetworkError.serverError(message: "Internal Server Error")

        // When
        let result = mapper.mapToConcertError(networkError)

        // Then
        #expect(result == .serverError)
    }

    @Test("unauthorized 에러 매핑")
    func test_에러매핑_unauthorized_unauthorized반환() {
        // Given
        let networkError = NetworkError.unauthorized(message: "Token expired")

        // When
        let result = mapper.mapToConcertError(networkError)

        // Then
        #expect(result == .unauthorized)
    }

    @Test("forbidden 에러 매핑")
    func test_에러매핑_forbidden_forbidden반환() {
        // Given
        let networkError = NetworkError.forbidden(message: "Access denied")

        // When
        let result = mapper.mapToConcertError(networkError)

        // Then
        #expect(result == .forbidden)
    }

    @Test("decodingFailed 에러 매핑")
    func test_에러매핑_decodingFailed_invalidResponse반환() {
        // Given
        let decodingError = DecodingError.dataCorrupted(.init(codingPath: [], debugDescription: ""))
        let networkError = NetworkError.decodingFailed(decodingError)

        // When
        let result = mapper.mapToConcertError(networkError)

        // Then
        #expect(result == .invalidResponse)
    }

    @Test("invalidResponse 에러 매핑")
    func test_에러매핑_invalidResponse_invalidResponse반환() {
        // Given
        let networkError = NetworkError.invalidResponse

        // When
        let result = mapper.mapToConcertError(networkError)

        // Then
        #expect(result == .invalidResponse)
    }

    @Test("알 수 없는 에러 매핑")
    func test_에러매핑_unknownError_unknown반환() {
        // Given
        let unknownError = NSError(domain: "TestError", code: 999)

        // When
        let result = mapper.mapToConcertError(unknownError)

        // Then
        #expect(result == .unknown)
    }

    @Test("badRequest 에러 매핑")
    func test_에러매핑_badRequest_unknown반환() {
        // Given
        let networkError = NetworkError.badRequest(message: "Bad Request")

        // When
        let result = mapper.mapToConcertError(networkError)

        // Then
        #expect(result == .unknown)
    }
}
