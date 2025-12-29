//
//  CommentRepositoryTests.swift
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

    @Test("댓글 작성")
    func test_댓글작성_실제API_댓글반환() async throws {
        // Given
        let concertID = 1549
        let content = "테스트 댓글입니다"

        // When
        let result = try await repository.createComment(concertID: concertID, content: content)

        // Then
        #expect(result.concertID == concertID)
        #expect(result.content == content)

        // Cleanup - 생성한 댓글 삭제
        try? await repository.deleteComment(commentID: result.id)
    }

    @Test("댓글 삭제")
    func test_댓글삭제_실제API_에러없음() async throws {
        // Given - 삭제할 댓글 먼저 생성
        let concertID = 1549
        let comment = try await repository.createComment(concertID: concertID, content: "삭제 테스트용 댓글")

        // When & Then - 에러 없이 삭제되면 성공
        try await repository.deleteComment(commentID: comment.id)
    }

    @Test("댓글 신고")
    func test_댓글신고_실제API_에러없음() async throws {
        // Given - 신고할 댓글 먼저 생성
        let concertID = 1549
        let comment = try await repository.createComment(concertID: concertID, content: "신고 테스트용 댓글")
        let reportContent = "테스트 신고 사유"

        // When & Then - 에러 없이 신고되면 성공
        try await repository.reportComment(commentID: comment.id, content: reportContent)

        // Cleanup
        try? await repository.deleteComment(commentID: comment.id)
    }

    // MARK: - Error Tests

    @Test("존재하지 않는 콘서트 댓글 조회 시 에러 발생")
    func test_댓글목록조회_존재하지않는ID_에러반환() async {
        // Given
        let invalidConcertID = -1

        // When & Then
        await #expect(throws: ConcertError.self) {
            try await repository.fetchConcertComments(concertID: invalidConcertID, cursor: nil, size: nil)
        }
    }

    @Test("존재하지 않는 댓글 삭제 시 에러 발생")
    func test_댓글삭제_존재하지않는ID_에러반환() async {
        // Given
        let invalidCommentID = -1

        // When & Then
        await #expect(throws: ConcertError.self) {
            try await repository.deleteComment(commentID: invalidCommentID)
        }
    }
}
