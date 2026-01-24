//
//  AuthMapperTests.swift
//  DataTests
//
//  Created by 김진웅 on 1/21/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import XCTest

import LivithNetwork
import Domain
@testable import AuthData

final class AuthMapperTests: XCTestCase {
    private var sut: AuthMapper!
    
    override func setUp() {
        super.setUp()
        sut = AuthMapper()
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    func test_CheckNicknameDuplicate_중복일때_available_false_반환되어야_한다() throws {
        // Given
        let json = """
        {
          "available": false
        }
        """.data(using: .utf8)!
        
        let dto = try JSONDecoder().decode(DTO.Response.CheckNicknameDuplicate.self, from: json)
        
        // When
        let result = sut.toDomain(from: dto)
        
        // Then
        XCTAssertFalse(result)
    }
    
    func test_CheckNicknameDuplicate_중복아닐때_available_true_반환되어야_한다() throws {
        // Given
        let json = """
        {
          "available": true
        }
        """.data(using: .utf8)!
        
        let dto = try JSONDecoder().decode(DTO.Response.CheckNicknameDuplicate.self, from: json)
        
        // When
        let result = sut.toDomain(from: dto)
        
        // Then
        XCTAssertTrue(result)
    }
    
    func test_FetchUserInfo를_User로_변환해야_한다() throws {
        // Given
        let json = """
        {
          "id": 123,
          "interestConcertId": 456,
          "provider": "kakao",
          "providerId": "provider123",
          "email": "test@example.com",
          "nickname": "테스트유저",
          "marketingConsent": true
        }
        """.data(using: .utf8)!
        
        let dto = try JSONDecoder().decode(DTO.Response.FetchUserInfo.self, from: json)
        
        // When
        let result = sut.toDomain(from: dto)
        
        // Then
        XCTAssertEqual(result.id, 123)
        XCTAssertEqual(result.interestConcertID, 456)
        XCTAssertEqual(result.provider, "kakao")
        XCTAssertEqual(result.providerID, "provider123")
        XCTAssertEqual(result.email, "test@example.com")
        XCTAssertEqual(result.nickname, "테스트유저")
        XCTAssertTrue(result.marketingConsent)
    }
    
    func test_FetchUserInfo_interestConcertId가_nil일때_변환해야_한다() throws {
        // Given
        let json = """
        {
          "id": 789,
          "interestConcertId": null,
          "provider": "apple",
          "providerId": "apple456",
          "email": null,
          "nickname": "애플유저",
          "marketingConsent": false
        }
        """.data(using: .utf8)!
        
        let dto = try JSONDecoder().decode(DTO.Response.FetchUserInfo.self, from: json)
        
        // When
        let result = sut.toDomain(from: dto)
        
        // Then
        XCTAssertEqual(result.id, 789)
        XCTAssertNil(result.interestConcertID)
        XCTAssertEqual(result.provider, "apple")
        XCTAssertEqual(result.providerID, "apple456")
        XCTAssertNil(result.email)
        XCTAssertEqual(result.nickname, "애플유저")
        XCTAssertFalse(result.marketingConsent)
    }
}

final class AuthErrorMapperTests: XCTestCase {
    private var sut: AuthErrorMapper!
    
    override func setUp() {
        super.setUp()
        sut = AuthErrorMapper()
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    func test_기본_네트워크_에러가_AuthError로_변환되어야_한다() {
        XCTAssertEqual(sut.mapToAuthError(NetworkError.noConnection(NSError(domain: "", code: -1))), .noConnection)
        XCTAssertEqual(sut.mapToAuthError(NetworkError.serverError(message: nil)), .serverError)
        XCTAssertEqual(sut.mapToAuthError(NetworkError.invalidRequest), .invalidResponse)
    }
    
    func test_메시지가_있는_에러는_해당_메시지에_매핑되는_AuthError로_변환되어야_한다() {
        let testCases: [(NetworkError, AuthError)] = [
            (.badRequest(message: "nickname should not be empty"), .emptyNickname),
            (.badRequest(message: "nickname must be shorter than or equal to 10 characters"), .nicknameTooLong),
            (.badRequest(message: "이미 존재하는 닉네임이에요."), .duplicateNickname),
            (.forbidden(message: "탈퇴한 회원입니다."), .withdrawn),
            (.badRequest(message: "reason should not be empty"), .emptyReason)
        ]
        
        testCases.forEach { networkError, expectedError in
            XCTAssertEqual(sut.mapToAuthError(networkError), expectedError, "Failed for error: \(networkError)")
        }
    }
    
    func test_취소_에러는_cancelled로_변환되어야_한다() {
        XCTAssertEqual(sut.mapToAuthError(CancellationError()), .cancelled)
        XCTAssertEqual(sut.mapToAuthError(URLError(.cancelled)), .cancelled)
        XCTAssertEqual(sut.mapToAuthError(NetworkError.unknown(URLError(.cancelled))), .cancelled)
    }
}
