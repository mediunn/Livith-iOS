//
//  SetlistRepositoryTests.swift
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

@Suite("SetlistRepository Tests")
struct SetlistRepositoryTests {
    let repository = SetlistRepositoryImpl()

    init() {
        TestTokenHelper.setupToken()
    }

    @Test("셋리스트 상세 조회")
    func test_셋리스트상세조회_실제API_셋리스트반환() async throws {
        // Given
        let setlistID = 1549

        // When
        let result = try await repository.fetchConcertSetlist(setlistID: setlistID)

        // Then
        #expect(result.id == setlistID)
    }

    @Test("셋리스트 곡 목록 조회")
    func test_셋리스트곡목록조회_실제API_곡목록반환() async throws {
        // Given
        let setlistID = 1549

        // When
        let result = try await repository.fetchSetlistSongList(setlistID: setlistID)

        // Then
        #expect(result.isEmpty == false)
    }
}
