//
//  ConcertRepositoryTests.swift
//  ConcertDataTests
//
//  Created by Youjin Lee on 12/25/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import Testing
import Foundation
import LivithNetwork

@testable import ConcertData
@testable import ConcertDomain

@Suite("ConcertRepository Tests")
struct ConcertRepositoryTests {
    let repository = ConcertRepositoryImpl()

    init() {
        TestTokenHelper.setupToken()
    }

    @Test("콘서트 정보 조회")
    func test_콘서트정보조회_실제API_콘서트반환() async throws {
        // Given
        let concertID = 1549

        // When
        let result = try await repository.fetchConcertInfo(concertID: concertID)

        // Then
        #expect(result.id == concertID)
    }

    @Test("콘서트 일정 조회")
    func test_콘서트일정조회_실제API_일정목록반환() async throws {
        // Given
        let concertID = 1549

        // When
        let result = try await repository.fetchConcertSchedule(concertID: concertID)

        // Then
        #expect(result.isEmpty == false)
    }

    @Test("콘서트 문화 목록 조회")
    func test_콘서트문화조회_실제API_문화목록반환() async throws {
        // Given
        let concertID = 1549

        // When
        let result = try await repository.fetchConcertCultureList(concertID: concertID)

        // Then
        #expect(result.isEmpty == false)
    }

    @Test("MD 목록 조회")
    func test_MD목록조회_실제API_MD목록반환() async throws {
        // Given
        let concertID = 1549

        // When
        let result = try await repository.fetchConcertMerchandiseList(concertID: concertID)

        // Then
        #expect(result.isEmpty == false)
    }

    @Test("아티스트 정보 조회")
    func test_아티스트정보조회_실제API_아티스트반환() async throws {
        // Given
        let concertID = 1549

        // When
        let result = try await repository.fetchConcertArtistInfo(concertID: concertID)

        // Then
        #expect(result.id > 0)
    }

    // MARK: - Error Tests

    @Test("존재하지 않는 콘서트 조회 시 에러 발생")
    func test_콘서트정보조회_존재하지않는ID_에러반환() async {
        // Given
        let invalidConcertID = -1

        // When & Then
        await #expect(throws: ConcertError.self) {
            try await repository.fetchConcertInfo(concertID: invalidConcertID)
        }
    }

    @Test("존재하지 않는 콘서트 일정 조회 시 에러 발생")
    func test_콘서트일정조회_존재하지않는ID_에러반환() async {
        // Given
        let invalidConcertID = -1

        // When & Then
        await #expect(throws: ConcertError.self) {
            try await repository.fetchConcertSchedule(concertID: invalidConcertID)
        }
    }

    @Test("존재하지 않는 콘서트 아티스트 조회 시 에러 발생")
    func test_아티스트정보조회_존재하지않는ID_에러반환() async {
        // Given
        let invalidConcertID = -1

        // When & Then
        await #expect(throws: ConcertError.self) {
            try await repository.fetchConcertArtistInfo(concertID: invalidConcertID)
        }
    }
}
