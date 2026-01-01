//
//  SetlistRepositoryTests.swift
//  ConcertTests
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

    // MARK: - Error Tests

    @Test("존재하지 않는 셋리스트 조회 시 에러 발생")
    func test_셋리스트상세조회_존재하지않는ID_에러반환() async {
        // Given
        let invalidSetlistID = -1

        // When & Then
        await #expect(throws: ConcertError.self) {
            try await repository.fetchConcertSetlist(setlistID: invalidSetlistID)
        }
    }
}
