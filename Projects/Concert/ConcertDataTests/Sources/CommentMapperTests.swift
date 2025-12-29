//
//  CommentMapperTests.swift
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

@Suite("CommentMapper Tests")
struct CommentMapperTests {
    let mapper = ConcertMapper()

    // MARK: - Comment List Tests

    @Test("댓글 목록 매핑")
    func test_댓글목록매핑_유효한응답_댓글목록반환() {
        // Given
        let response = DTO.Response.FetchConcertCommentList(
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

        // When
        let result = mapper.toDomain(from: response)

        // Then
        #expect(result.comments.count == 1)
        #expect(result.comments[0].nickname == "유저1")
        #expect(result.totalCount == 1)
        #expect(result.cursor != nil)
    }

    @Test("댓글 목록 커서가 nil일 때 매핑")
    func test_댓글목록매핑_nil커서_nil커서반환() {
        // Given
        let response = DTO.Response.FetchConcertCommentList(
            data: [],
            cursor: nil,
            totalCount: 0
        )

        // When
        let result = mapper.toDomain(from: response)

        // Then
        #expect(result.comments.isEmpty)
        #expect(result.totalCount == 0)
        #expect(result.cursor == nil)
    }

    // MARK: - Create Comment Tests

    @Test("댓글 생성 매핑")
    func test_댓글생성매핑_유효한응답_댓글반환() {
        // Given
        let response = DTO.Response.CreateConcertComment(
            id: 1,
            userID: 100,
            nickname: "유저1",
            concertID: 1,
            content: "댓글 내용",
            createdAt: "2025-01-01T12:00:00Z"
        )

        // When
        let result = mapper.toDomain(from: response)

        // Then
        #expect(result.id == 1)
        #expect(result.userID == 100)
        #expect(result.nickname == "유저1")
        #expect(result.content == "댓글 내용")
    }
}
