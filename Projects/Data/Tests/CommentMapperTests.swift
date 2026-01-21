//
//  CommentMapperTests.swift
//  DataTests
//
//  Created by 김진웅 on 1/21/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import XCTest

import LivithNetwork
import Domain
@testable import Data

final class CommentMapperTests: XCTestCase {
    private var sut: CommentMapper!
    
    override func setUp() {
        super.setUp()
        sut = CommentMapper()
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    func test_FetchConcertCommentList_DTO가_올바르게_매핑되어야_한다() throws {
        // Given
        let json = """
        {
          "data": [
            {
              "id": 11,
              "userId": 1,
              "nickname": "라이빗",
              "concertId": 8,
              "content": "이번 공연 너무 기대돼요!",
              "createdAt": "2025-10-11T15:07:31.000Z"
            },
            {
              "id": 25,
              "userId": 1,
              "nickname": "라이빗",
              "concertId": 8,
              "content": "티켓 예매 성공!",
              "createdAt": "2025-10-11T14:07:31.000Z"
            },
            {
              "id": 19,
              "userId": 2,
              "nickname": "이빗",
              "concertId": 8,
              "content": "공연장 주변 맛집 추천해주세요.",
              "createdAt": "2025-10-11T12:07:31.000Z"
            },
            {
              "id": 22,
              "userId": 2,
              "nickname": "이빗",
              "concertId": 8,
              "content": "오프닝 무대가 기대돼요!",
              "createdAt": "2025-10-11T05:07:31.000Z"
            }
          ],
          "cursor": {
            "createdAt": "2025-10-11T05:07:31.000Z",
            "id": 22
          },
          "totalCount": 6
        }
        """.data(using: .utf8)!
        
        let dto = try JSONDecoder().decode(DTO.Response.FetchConcertCommentList.self, from: json)
        
        // When
        let result = sut.toDomain(from: dto)
        
        // Then
        XCTAssertEqual(result.comments.count, 4)
        XCTAssertEqual(result.comments[0].id, 11)
        XCTAssertEqual(result.comments[0].writer, "라이빗")
        XCTAssertEqual(result.comments[0].content, "이번 공연 너무 기대돼요!")
        XCTAssertEqual(result.cursor?.id, 22)
        XCTAssertEqual(result.cursor?.createdAt, "2025-10-11T05:07:31.000Z")
        XCTAssertEqual(result.totalCount, 6)
    }
    
    func test_CreateConcertComment_DTO가_ConcertComment로_매핑되어야_한다() throws {
        // Given
        let json = """
        {
          "id": 29,
          "userId": 1,
          "nickname": "라이빗",
          "concertId": 8,
          "content": "기대기대",
          "createdAt": "2025-10-12T07:46:33.113Z"
        }
        """.data(using: .utf8)!
        
        let dto = try JSONDecoder().decode(DTO.Response.CreateConcertComment.self, from: json)
        
        // When
        let result = sut.toDomain(from: dto)
        
        // Then
        XCTAssertEqual(result.id, 29)
        XCTAssertEqual(result.writer, "라이빗")
        XCTAssertEqual(result.content, "기대기대")
        
        // Date verification
        let calendar = Calendar.current
        let year = calendar.component(.year, from: result.createdAt)
        XCTAssertEqual(year, 2025)
    }
}

final class CommentErrorMapperTests: XCTestCase {
    private var sut: CommentErrorMapper!
    
    override func setUp() {
        super.setUp()
        sut = CommentErrorMapper()
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    func test_네트워크_연결_없음_에러는_noConnection으로_변환되어야_한다() {
        let error = NetworkError.noConnection(NSError(domain: "", code: -1))
        XCTAssertEqual(sut.mapToCommentError(error), .noConnection)
    }
    
    func test_서버_에러는_serverError로_변환되어야_한다() {
        let error = NetworkError.serverError(message: nil)
        XCTAssertEqual(sut.mapToCommentError(error), .serverError)
    }
    
    func test_권한_에러는_forbidden으로_변환되어야_한다() {
        XCTAssertEqual(sut.mapToCommentError(NetworkError.unauthorized(message: nil)), .forbidden)
        XCTAssertEqual(sut.mapToCommentError(NetworkError.forbidden(message: nil)), .forbidden)
    }
    
    func test_메시지가_있는_에러는_해당_메시지에_매핑되는_에러로_변환되어야_한다() {
        let testCases: [(NetworkError, CommentError)] = [
            (.notFound(message: "해당 콘서트가 존재하지 않습니다."), .concertNotFound),
            (.badRequest(message: "id는 양의 정수여야 합니다."), .invalidID),
            (.badRequest(message: "size must not be less than 1"), .invalidSize),
            (.badRequest(message: "유효하지 않은 cursor 형식입니다."), .invalidCursor),
            (.badRequest(message: "content should not be empty"), .emptyContent),
            (.badRequest(message: "content must be shorter than or equal to 400 characters"), .contentTooLong),
            (.notFound(message: "해당 유저가 존재하지 않습니다."), .userNotFound),
            (.forbidden(message: "탈퇴한 회원입니다."), .withdrawn),
            (.notFound(message: "댓글을 찾을 수 없습니다."), .commentNotFound),
            (.forbidden(message: "본인의 댓글만 삭제할 수 있습니다."), .forbidden),
            (.badRequest(message: "content must be shorter than or equal to 200 characters"), .reportReasonTooLong)
        ]
        
        testCases.forEach { networkError, expectedError in
            var expected = expectedError
            if case .unauthorized(let msg) = networkError, msg == "Unauthorized" {
                expected = .forbidden
            }
            
            XCTAssertEqual(sut.mapToCommentError(networkError), expected, "Failed for error: \(networkError)")
        }
    }
    
    func test_토큰_유효하지_않은_경우_Forbidden_반환_확인() {
        let error = NetworkError.unauthorized(message: "Unauthorized")
        XCTAssertEqual(sut.mapToCommentError(error), .forbidden)
    }
    
    func test_취소_에러는_cancelled로_변환되어야_한다() {
         XCTAssertEqual(sut.mapToCommentError(CancellationError()), .cancelled)
         XCTAssertEqual(sut.mapToCommentError(URLError(.cancelled)), .cancelled)
         XCTAssertEqual(sut.mapToCommentError(NetworkError.unknown(URLError(.cancelled))), .cancelled)
    }
}
