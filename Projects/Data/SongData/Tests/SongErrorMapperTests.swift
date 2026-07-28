//
//  SongErrorMapperTests.swift
//  DataTests
//
//  Created by 김진웅 on 1/21/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import XCTest

import LivithNetworking
import Domain
@testable import SongData

final class SongErrorMapperTests: XCTestCase {
    private var sut: SongErrorMapper!

    override func setUp() {
        super.setUp()
        sut = SongErrorMapper()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    func test_네트워크_연결_없음_에러는_noConnection으로_변환되어야_한다() {
        // Given
        let networkError = NetworkError.noConnection(NSError(domain: "", code: -1))

        // When
        let result = sut.mapToSongError(networkError)

        // Then
        XCTAssertEqual(result, .noConnection)
    }

    func test_서버_에러는_serverError로_변환되어야_한다() {
        // Given
        let networkError = NetworkError.serverError(statusCode: 500, message: nil)

        // When
        let result = sut.mapToSongError(networkError)

        // Then
        XCTAssertEqual(result, .serverError)
    }

    func test_데이터_없음_에러는_notFound로_변환되어야_한다() {
        // Given
        let networkError = NetworkError.noData

        // When
        let result = sut.mapToSongError(networkError)

        // Then
        XCTAssertEqual(result, .notFound)
    }
    
    func test_찾을수_없음_에러는_notFound로_변환되어야_한다() {
        // Given
        let networkError = NetworkError.notFound(message: nil)

        // When
        let result = sut.mapToSongError(networkError)

        // Then
        XCTAssertEqual(result, .notFound)
    }

    func test_잘못된_요청_관련_에러들은_invalidResponse로_변환되어야_한다() {
        // Given
        let errors: [NetworkError] = [
            .decodingFailed(NSError(domain: "", code: -1)),
            .invalidURL,
            .invalidRequest,
            .invalidResponse,
            .badRequest(message: nil),
            .clientError(statusCode: 400, message: nil)
        ]

        errors.forEach { error in
            // When
            let result = sut.mapToSongError(error)

            // Then
            XCTAssertEqual(result, .invalidResponse, "Failed for error: \(error)")
        }
    }

    func test_인증_및_권한_관련_에러와_알수없는_에러는_unknown으로_변환되어야_한다() {
        // Given
        let errors: [NetworkError] = [
            .unauthorized(message: nil),
            .forbidden(message: nil),
            .unknown(NSError(domain: "", code: -1))
        ]

        errors.forEach { error in
            // When
            let result = sut.mapToSongError(error)

            // Then
            XCTAssertEqual(result, .unknown, "Failed for error: \(error)")
        }
    }

    func test_일반_Error_타입도_알맞게_변환되어야_한다() {
         // Given
         let error: Error = NetworkError.noConnection(NSError(domain: "", code: -1))

         // When
         let result = sut.mapToSongError(error)

         // Then
         XCTAssertEqual(result, .noConnection)
    }
    
    func test_NetworkError가_아닌_에러는_unknown으로_변환되어야_한다() {
        // Given
        struct SomeError: Error {}
        let error = SomeError()

        // When
        let result = sut.mapToSongError(error)

        // Then
        XCTAssertEqual(result, .unknown)
    }
    func test_메시지가_있는_에러는_해당_메시지에_매핑되는_에러로_변환되어야_한다() {
        // Given
        let testCases: [(NetworkError, SongError)] = [
            (.badRequest(message: "id는 양의 정수여야 합니다."), .invalidID),
            (.notFound(message: "해당 곡이 존재하지 않습니다."), .notFound),
            (.badRequest(message: "id는 양의 정수여야 합니다."), .invalidID),
            (.notFound(message: "해당 셋리스트가 존재하지 않습니다."), .setlistNotFound),
            (.notFound(message: "해당 곡이 존재하지 않습니다."), .notFound),
            (.notFound(message: "해당 셋리스트와 곡의 조합이 존재하지 않습니다."), .combinationNotFound)
        ]
        
        testCases.forEach { networkError, expectedError in
            // When
            let result = sut.mapToSongError(networkError)
            
            // Then
            XCTAssertEqual(result, expectedError, "Failed for error: \(networkError)")
        }
    }
    
    func test_취소_에러는_cancelled로_변환되어야_한다() {
        // Given
        let cancellationError = CancellationError()
        let urlCancelledError = URLError(.cancelled)
        let networkCancelledError = NetworkError.unknown(URLError(.cancelled))
        let networkNoConnectionCancelledError = NetworkError.noConnection(URLError(.cancelled))

        // When & Then
        XCTAssertEqual(sut.mapToSongError(cancellationError), .cancelled)
        XCTAssertEqual(sut.mapToSongError(urlCancelledError), .cancelled)
        XCTAssertEqual(sut.mapToSongError(networkCancelledError), .cancelled)
        XCTAssertEqual(sut.mapToSongError(networkNoConnectionCancelledError), .cancelled)
    }
}
