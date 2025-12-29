//
//  CommentRepositoryTests.swift
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

@Suite("CommentRepository Tests")
struct CommentRepositoryTests {
    let repository = CommentRepositoryImpl()

    init() {
        TestTokenHelper.setupToken()
    }

    @Test("댓글 목록 조회")
    func test_댓글목록조회_실제API_댓글목록반환() async throws {
        // Given
        let concertID = 1549

        // When
        let result = try await repository.fetchConcertComments(concertID: concertID, cursor: nil, size: nil)

        // Then
        #expect(result.totalCount >= 0)
    }
}
