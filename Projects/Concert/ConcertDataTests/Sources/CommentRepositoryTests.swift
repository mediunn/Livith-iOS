//
//  CommentRepositoryTests.swift
//  ConcertDataTests
//
//  Created by Youjin Lee on 12/25/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import Testing
import Foundation

@testable import ConcertData
@testable import ConcertDomain
@testable import LivithNetwork

@Suite("CommentRepository Tests")
struct CommentRepositoryTests {

    // MARK: - FetchConcertComments Tests

    @Test("댓글 목록 조회 성공")
    func test_댓글목록조회_유효한응답_댓글목록반환() async throws {
        // Given
        let mockService = MockCommentService()
        mockService.mockResponse = DTO.Response.FetchConcertCommentList(
            data: [
                DTO.Response.FetchConcertCommentList.Comment(
                    id: 1,
                    userID: 100,
                    nickname: "유저1",
                    concertID: 1,
                    content: "기대돼요!",
                    createdAt: "2025-01-01T12:00:00Z"
                )
            ],
            cursor: DTO.Response.FetchConcertCommentList.Cursor(createdAt: "2025-01-01T12:00:00Z", id: 1),
            totalCount: 1
        )
        let repository = CommentRepositoryImpl(service: mockService)

        // When
        let result = try await repository.fetchConcertComments(concertID: 1, cursor: nil, size: nil)

        // Then
        #expect(result.comments.count == 1)
        #expect(result.comments[0].nickname == "유저1")
        #expect(result.totalCount == 1)
    }

    @Test("댓글 목록 조회 실패 - 네트워크 에러")
    func test_댓글목록조회_네트워크에러_에러반환() async {
        // Given
        let mockService = MockCommentService()
        mockService.mockError = NetworkError.serverError(message: nil)
        let repository = CommentRepositoryImpl(service: mockService)

        // When & Then
        do {
            _ = try await repository.fetchConcertComments(concertID: 1, cursor: nil, size: nil)
            Issue.record("에러가 발생해야 합니다")
        } catch {
            #expect(error == .serverError)
        }
    }

    // MARK: - CreateComment Tests

    @Test("댓글 생성 성공")
    func test_댓글생성_유효한응답_댓글반환() async throws {
        // Given
        let mockService = MockCommentService()
        mockService.mockResponse = DTO.Response.CreateConcertComment(
            id: 1,
            userID: 100,
            nickname: "유저1",
            concertID: 1,
            content: "댓글 내용",
            createdAt: "2025-01-01T12:00:00Z"
        )
        let repository = CommentRepositoryImpl(service: mockService)

        // When
        let result = try await repository.createComment(concertID: 1, content: "댓글 내용")

        // Then
        #expect(result.id == 1)
        #expect(result.content == "댓글 내용")
    }

    @Test("댓글 생성 실패 - 네트워크 에러")
    func test_댓글생성_네트워크에러_에러반환() async {
        // Given
        let mockService = MockCommentService()
        mockService.mockError = NetworkError.unauthorized(message: nil)
        let repository = CommentRepositoryImpl(service: mockService)

        // When & Then
        do {
            _ = try await repository.createComment(concertID: 1, content: "댓글")
            Issue.record("에러가 발생해야 합니다")
        } catch {
            #expect(error == .unauthorized)
        }
    }

    // MARK: - DeleteComment Tests

    @Test("댓글 삭제 성공")
    func test_댓글삭제_유효한응답_성공() async throws {
        // Given
        let mockService = MockCommentService()
        mockService.mockResponse = DTO.Response.EmptyResponse()
        let repository = CommentRepositoryImpl(service: mockService)

        // When & Then
        try await repository.deleteComment(commentID: 1)
    }

    @Test("댓글 삭제 실패 - 네트워크 에러")
    func test_댓글삭제_네트워크에러_에러반환() async {
        // Given
        let mockService = MockCommentService()
        mockService.mockError = NetworkError.forbidden(message: nil)
        let repository = CommentRepositoryImpl(service: mockService)

        // When & Then
        do {
            try await repository.deleteComment(commentID: 1)
            Issue.record("에러가 발생해야 합니다")
        } catch {
            #expect(error == .forbidden)
        }
    }

    // MARK: - ReportComment Tests

    @Test("댓글 신고 성공")
    func test_댓글신고_유효한응답_성공() async throws {
        // Given
        let mockService = MockCommentService()
        mockService.mockResponse = DTO.Response.CreateCommentReport(
            id: 1,
            commentID: 1,
            commentUserID: 100,
            commentContent: "신고된 댓글",
            reportReason: "부적절한 내용",
            createdAt: "2025-01-01T12:00:00Z"
        )
        let repository = CommentRepositoryImpl(service: mockService)

        // When & Then
        try await repository.reportComment(commentID: 1, content: "부적절한 내용")
    }

    @Test("댓글 신고 실패 - 네트워크 에러")
    func test_댓글신고_네트워크에러_에러반환() async {
        // Given
        let mockService = MockCommentService()
        mockService.mockError = NetworkError.badRequest(message: nil)
        let repository = CommentRepositoryImpl(service: mockService)

        // When & Then
        do {
            try await repository.reportComment(commentID: 1, content: nil)
            Issue.record("에러가 발생해야 합니다")
        } catch {
            #expect(error == .badRequest)
        }
    }
}
