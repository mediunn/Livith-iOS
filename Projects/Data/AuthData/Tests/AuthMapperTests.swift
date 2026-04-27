//
//  AuthMapperTests.swift
//  DataTests
//
//  Created by 김진웅 on 1/21/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation
import Testing

import LivithNetwork
import Domain
@testable import AuthData

@Suite("인증 매퍼 테스트")
struct AuthMapperTests {
    @Test("닉네임이 중복이면 false로 변환해야 한다")
    func checkNicknameDuplicate_중복이면_false로_변환해야_한다() throws {
        // Given
        let sut = AuthMapper()
        let json = """
        {
          "available": false
        }
        """.data(using: .utf8)!
        let dto = try JSONDecoder().decode(DTO.Response.CheckNicknameDuplicate.self, from: json)

        // When
        let result = sut.toDomain(from: dto)

        // Then
        #expect(!result)
    }

    @Test("닉네임이 중복이 아니면 true로 변환해야 한다")
    func checkNicknameDuplicate_중복이_아니면_true로_변환해야_한다() throws {
        // Given
        let sut = AuthMapper()
        let json = """
        {
          "available": true
        }
        """.data(using: .utf8)!
        let dto = try JSONDecoder().decode(DTO.Response.CheckNicknameDuplicate.self, from: json)

        // When
        let result = sut.toDomain(from: dto)

        // Then
        #expect(result)
    }

    @Test("FetchUserInfo를 User로 변환해야 한다")
    func fetchUserInfo를_User로_변환해야_한다() throws {
        // Given
        let sut = AuthMapper()
        let json = """
        {
          "id": 123,
          "provider": "kakao",
          "providerId": "provider123",
          "email": "test@example.com",
          "nickname": "테스트유저",
          "marketingConsent": true,
          "hasPreferredGenre": true
        }
        """.data(using: .utf8)!
        let dto = try JSONDecoder().decode(DTO.Response.FetchUserInfo.self, from: json)

        // When
        let result = sut.toDomain(from: dto)

        // Then
        #expect(result.id == 123)
        #expect(result.interestConcertID == nil)
        #expect(result.provider == "kakao")
        #expect(result.providerID == "provider123")
        #expect(result.email == "test@example.com")
        #expect(result.nickname == "테스트유저")
        #expect(result.hasPreferences)
        #expect(result.authority.marketingConsent)
    }

    @Test("FetchUserInfo의 Optional 필드가 null이어도 User로 변환해야 한다")
    func fetchUserInfo_Optional필드가_null이어도_User로_변환해야_한다() throws {
        // Given
        let sut = AuthMapper()
        let json = """
        {
          "id": 789,
          "provider": "apple",
          "providerId": "apple456",
          "email": null,
          "nickname": "애플유저",
          "marketingConsent": false,
          "hasPreferredGenre": false
        }
        """.data(using: .utf8)!
        let dto = try JSONDecoder().decode(DTO.Response.FetchUserInfo.self, from: json)

        // When
        let result = sut.toDomain(from: dto)

        // Then
        #expect(result.id == 789)
        #expect(result.interestConcertID == nil)
        #expect(result.provider == "apple")
        #expect(result.providerID == "apple456")
        #expect(result.email == nil)
        #expect(result.nickname == "애플유저")
        #expect(!result.hasPreferences)
        #expect(!result.authority.marketingConsent)
    }
}

@Suite("인증 에러 매퍼 테스트")
struct AuthErrorMapperTests {
    @Test("기본 네트워크 에러를 AuthError로 변환해야 한다")
    func 기본_네트워크_에러를_AuthError로_변환해야_한다() {
        // Given
        let sut = AuthErrorMapper()

        // When & Then
        #expect(sut.mapToAuthError(NetworkError.noConnection(NSError(domain: "", code: -1))) == .noConnection)
        #expect(sut.mapToAuthError(NetworkError.serverError(message: nil)) == .serverError)
        #expect(sut.mapToAuthError(NetworkError.invalidRequest) == .invalidResponse)
    }

    @Test("메시지가 있는 에러를 해당 AuthError로 변환해야 한다")
    func 메시지가_있는_에러를_해당_AuthError로_변환해야_한다() {
        // Given
        let sut = AuthErrorMapper()
        let testCases: [(NetworkError, AuthError)] = [
            (.badRequest(message: "nickname should not be empty"), .emptyNickname),
            (.badRequest(message: "nickname must be shorter than or equal to 10 characters"), .nicknameTooLong),
            (.badRequest(message: "이미 존재하는 닉네임이에요."), .duplicateNickname),
            (.forbidden(message: "탈퇴한 회원입니다."), .withdrawn),
            (.forbidden(message: "이미 탈퇴한 회원입니다."), .withdrawn),
            (.badRequest(message: "reason should not be empty"), .emptyReason)
        ]

        for (networkError, expectedError) in testCases {
            // When
            let result = sut.mapToAuthError(networkError)

            // Then
            #expect(result == expectedError)
        }
    }

    @Test("취소 에러를 cancelled로 변환해야 한다")
    func 취소_에러를_cancelled로_변환해야_한다() {
        // Given
        let sut = AuthErrorMapper()

        // When & Then
        #expect(sut.mapToAuthError(CancellationError()) == .cancelled)
        #expect(sut.mapToAuthError(URLError(.cancelled)) == .cancelled)
        #expect(sut.mapToAuthError(NetworkError.unknown(URLError(.cancelled))) == .cancelled)
    }
}
