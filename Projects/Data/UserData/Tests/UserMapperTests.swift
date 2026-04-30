//
//  UserMapperTests.swift
//  DataTests
//
//  Created by 김진웅 on 2026/01/22.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation
import Testing

import LivithNetwork
import Domain
@testable import UserData

@Suite("유저 매퍼 테스트")
struct UserMapperTests {
    @Test("UpdateUserNickname의 모든 필드를 User로 변환해야 한다")
    func updateUserNickname의_모든_필드를_User로_변환해야_한다() throws {
        // Given
        let sut = UserMapper()
        let json = """
        {
            "id": 1,
            "interestConcertId": 100,
            "provider": "kakao",
            "providerId": "4484239560",
            "email": "test@example.com",
            "nickname": "라이빗",
            "marketingConsent": true
        }
        """.data(using: .utf8)!
        let dto = try JSONDecoder().decode(DTO.Response.UpdateUserNickname.self, from: json)

        // When
        let result = sut.toDomain(from: dto)

        // Then
        #expect(result.id == 1)
        #expect(result.provider == "kakao")
        #expect(result.providerID == "4484239560")
        #expect(result.email == "test@example.com")
        #expect(result.nickname == "라이빗")
        #expect(result.authority.marketingConsent)
    }

    @Test("UpdateUserNickname의 Optional 필드가 null이어도 User로 변환해야 한다")
    func updateUserNickname의_Optional필드가_null이어도_User로_변환해야_한다() throws {
        // Given
        let sut = UserMapper()
        let json = """
        {
            "id": 1,
            "interestConcertId": null,
            "provider": "kakao",
            "providerId": "4484239560",
            "email": null,
            "nickname": "라이빗",
            "marketingConsent": false
        }
        """.data(using: .utf8)!
        let dto = try JSONDecoder().decode(DTO.Response.UpdateUserNickname.self, from: json)

        // When
        let result = sut.toDomain(from: dto)

        // Then
        #expect(result.id == 1)
        #expect(result.provider == "kakao")
        #expect(result.providerID == "4484239560")
        #expect(result.email == nil)
        #expect(result.nickname == "라이빗")
        #expect(!result.authority.marketingConsent)
    }

    @Test("FetchUserInfo의 모든 필드를 User로 변환해야 한다")
    func fetchUserInfo의_모든_필드를_User로_변환해야_한다() throws {
        // Given
        let sut = UserMapper()
        let json = """
        {
            "id": 42,
            "provider": "apple",
            "providerId": "001234.abcd1234",
            "email": "user@icloud.com",
            "nickname": "테스트유저",
            "marketingConsent": true,
            "hasPreferredGenre": true
        }
        """.data(using: .utf8)!
        let dto = try JSONDecoder().decode(DTO.Response.FetchUserInfo.self, from: json)

        // When
        let result = sut.toDomain(from: dto)

        // Then
        #expect(result.id == 42)
        #expect(result.provider == "apple")
        #expect(result.providerID == "001234.abcd1234")
        #expect(result.email == "user@icloud.com")
        #expect(result.nickname == "테스트유저")
        #expect(result.hasPreferences)
        #expect(result.authority.marketingConsent)
    }

    @Test("FetchUserInfo의 Optional 필드가 null이어도 User로 변환해야 한다")
    func fetchUserInfo의_Optional필드가_null이어도_User로_변환해야_한다() throws {
        // Given
        let sut = UserMapper()
        let json = """
        {
            "id": 99,
            "provider": "kakao",
            "providerId": null,
            "email": null,
            "nickname": "익명",
            "marketingConsent": false,
            "hasPreferredGenre": false
        }
        """.data(using: .utf8)!
        let dto = try JSONDecoder().decode(DTO.Response.FetchUserInfo.self, from: json)

        // When
        let result = sut.toDomain(from: dto)

        // Then
        #expect(result.id == 99)
        #expect(result.provider == "kakao")
        #expect(result.providerID == nil)
        #expect(result.email == nil)
        #expect(result.nickname == "익명")
        #expect(!result.hasPreferences)
        #expect(!result.authority.marketingConsent)
    }

    @Test("FetchUserInterestConcert의 모든 필드를 Concert로 변환해야 한다")
    func fetchUserInterestConcert의_모든_필드를_Concert로_변환해야_한다() throws {
        // Given
        let sut = UserMapper()
        let json = """
        {
            "id": 8,
            "code": "PF268438",
            "title": "제이크 밀러 첫 단독 내한공연 JAKE MILLER BALANCE TOUR",
            "startDate": "2025.09.27",
            "endDate": "2025.09.27",
            "status": "COMPLETED",
            "poster": "http://www.kopis.or.kr/upload/pfmPoster/PF_PF268438_250703_114113.gif",
            "artist": "JAKE MILLER (제이크 밀러)",
            "daysLeft": -16,
            "ticketSite": "NOL 티켓",
            "ticketUrl": "https://tickets.interpark.com/goods/25009244",
            "venue": "무신사 개러지",
            "introduction": "데뷔 10년 만에 드디어 한국 상륙! 제이크 밀러, 첫 단독 내한 'BALANCE TOUR'로 잊지 못할 밤을 선사!",
            "label": "첫 단독 내한 콘서트"
        }
        """.data(using: .utf8)!
        let dto = try JSONDecoder().decode(DTO.Response.FetchUserInterestConcert.self, from: json)

        // When
        let result = try #require(sut.toDomain(from: dto))

        // Then
        #expect(result.id == 8)
        #expect(result.title == "제이크 밀러 첫 단독 내한공연 JAKE MILLER BALANCE TOUR")
        #expect(result.artist == "JAKE MILLER (제이크 밀러)")
        #expect(result.status == .completed)
        #expect(result.posterURL.absoluteString == "http://www.kopis.or.kr/upload/pfmPoster/PF_PF268438_250703_114113.gif")
        #expect(result.venue == "무신사 개러지")
        #expect(result.ticketingOffice == "NOL 티켓")
        #expect(result.ticketingOfficeURL?.absoluteString == "https://tickets.interpark.com/goods/25009244")
        #expect(result.introduction == "데뷔 10년 만에 드디어 한국 상륙! 제이크 밀러, 첫 단독 내한 'BALANCE TOUR'로 잊지 못할 밤을 선사!")
        #expect(result.label == "첫 단독 내한 콘서트")
    }

    @Test("FetchUserInterestConcert의 Optional 필드가 null이어도 Concert로 변환해야 한다")
    func fetchUserInterestConcert의_Optional필드가_null이어도_Concert로_변환해야_한다() throws {
        // Given
        let sut = UserMapper()
        let json = """
        {
            "id": 2,
            "code": "CONCERT-002",
            "title": "버스커버스커 공연",
            "startDate": "2026.04.15",
            "endDate": "2026.04.15",
            "status": "ONGOING",
            "poster": "https://example.com/busker.jpg",
            "artist": "버스커버스커",
            "daysLeft": 0,
            "ticketSite": null,
            "ticketUrl": null,
            "venue": "홍대 놀이터",
            "introduction": "무료 게릴라 공연",
            "label": null
        }
        """.data(using: .utf8)!
        let dto = try JSONDecoder().decode(DTO.Response.FetchUserInterestConcert.self, from: json)

        // When
        let result = try #require(sut.toDomain(from: dto))

        // Then
        #expect(result.id == 2)
        #expect(result.title == "버스커버스커 공연")
        #expect(result.artist == "버스커버스커")
        #expect(result.status == .ongoing)
        #expect(result.posterURL.absoluteString == "https://example.com/busker.jpg")
        #expect(result.venue == "홍대 놀이터")
        #expect(result.ticketingOffice == nil)
        #expect(result.ticketingOfficeURL == nil)
        #expect(result.introduction == "무료 게릴라 공연")
        #expect(result.label == nil)
    }

    @Test("UpdateUserInterestConcert의 모든 필드를 Concert로 변환해야 한다")
    func updateUserInterestConcert의_모든_필드를_Concert로_변환해야_한다() throws {
        // Given
        let sut = UserMapper()
        let json = """
        {
            "id": 8,
            "code": "PF268438",
            "title": "제이크 밀러 첫 단독 내한공연 JAKE MILLER BALANCE TOUR",
            "startDate": "2025.09.27",
            "endDate": "2025.09.27",
            "status": "COMPLETED",
            "poster": "http://www.kopis.or.kr/upload/pfmPoster/PF_PF268438_250703_114113.gif",
            "artist": "JAKE MILLER (제이크 밀러)",
            "ticketSite": "NOL 티켓",
            "ticketUrl": "https://tickets.interpark.com/goods/25009244",
            "venue": "무신사 개러지",
            "introduction": "데뷔 10년 만에 드디어 한국 상륙! 제이크 밀러, 첫 단독 내한 'BALANCE TOUR'로 잊지 못할 밤을 선사!",
            "label": "첫 단독 내한 콘서트"
        }
        """.data(using: .utf8)!
        let dto = try JSONDecoder().decode(DTO.Response.UpdateUserInterestConcert.self, from: json)

        // When
        let result = try #require(sut.toDomain(from: dto))

        // Then
        #expect(result.id == 8)
        #expect(result.title == "제이크 밀러 첫 단독 내한공연 JAKE MILLER BALANCE TOUR")
        #expect(result.artist == "JAKE MILLER (제이크 밀러)")
        #expect(result.status == .completed)
        #expect(result.posterURL.absoluteString == "http://www.kopis.or.kr/upload/pfmPoster/PF_PF268438_250703_114113.gif")
        #expect(result.venue == "무신사 개러지")
        #expect(result.ticketingOffice == "NOL 티켓")
        #expect(result.ticketingOfficeURL?.absoluteString == "https://tickets.interpark.com/goods/25009244")
        #expect(result.introduction == "데뷔 10년 만에 드디어 한국 상륙! 제이크 밀러, 첫 단독 내한 'BALANCE TOUR'로 잊지 못할 밤을 선사!")
        #expect(result.label == "첫 단독 내한 콘서트")
    }

    @Test("UpdateUserInterestConcert의 Optional 필드가 null이어도 Concert로 변환해야 한다")
    func updateUserInterestConcert의_Optional필드가_null이어도_Concert로_변환해야_한다() throws {
        // Given
        let sut = UserMapper()
        let json = """
        {
            "id": 10,
            "code": "CONCERT-010",
            "title": "무료 버스킹 공연",
            "startDate": "2026.05.01",
            "endDate": "2026.05.01",
            "status": "UPCOMING",
            "poster": "https://example.com/busking.jpg",
            "artist": "인디 밴드",
            "ticketSite": null,
            "ticketUrl": null,
            "venue": "신촌 연세로",
            "introduction": "무료로 즐기는 버스킹 공연",
            "label": null
        }
        """.data(using: .utf8)!
        let dto = try JSONDecoder().decode(DTO.Response.UpdateUserInterestConcert.self, from: json)

        // When
        let result = try #require(sut.toDomain(from: dto))

        // Then
        #expect(result.id == 10)
        #expect(result.title == "무료 버스킹 공연")
        #expect(result.artist == "인디 밴드")
        #expect(result.status == .upcoming)
        #expect(result.posterURL.absoluteString == "https://example.com/busking.jpg")
        #expect(result.venue == "신촌 연세로")
        #expect(result.ticketingOffice == nil)
        #expect(result.ticketingOfficeURL == nil)
        #expect(result.introduction == "무료로 즐기는 버스킹 공연")
        #expect(result.label == nil)
    }
}

@Suite("유저 에러 매퍼 테스트")
struct UserErrorMapperTests {
    @Test("네트워크 연결 없음 에러를 noConnection으로 변환해야 한다")
    func 네트워크_연결_없음_에러를_noConnection으로_변환해야_한다() {
        // Given
        let sut = UserErrorMapper()
        let networkError = NetworkError.noConnection(NSError(domain: "", code: -1))

        // When
        let result = sut.mapToUserError(networkError)

        // Then
        #expect(result == .noConnection)
    }

    @Test("서버 에러를 serverError로 변환해야 한다")
    func 서버_에러를_serverError로_변환해야_한다() {
        // Given
        let sut = UserErrorMapper()
        let networkError = NetworkError.serverError(message: nil)

        // When
        let result = sut.mapToUserError(networkError)

        // Then
        #expect(result == .serverError)
    }

    @Test("잘못된 요청 관련 에러를 invalidResponse로 변환해야 한다")
    func 잘못된_요청_관련_에러를_invalidResponse로_변환해야_한다() {
        // Given
        let sut = UserErrorMapper()
        let errorList: [NetworkError] = [
            .noData,
            .decodingFailed(NSError(domain: "", code: -1)),
            .invalidURL,
            .invalidRequest,
            .invalidResponse,
            .clientError(statusCode: 400, message: nil)
        ]

        for error in errorList {
            // When
            let result = sut.mapToUserError(error)

            // Then
            #expect(result == .invalidResponse)
        }
    }

    @Test("메시지 기반 에러를 올바른 UserError로 변환해야 한다")
    func 메시지_기반_에러를_올바른_UserError로_변환해야_한다() {
        // Given
        let sut = UserErrorMapper()
        let testCases: [(NetworkError, UserError)] = [
            (.notFound(message: "해당 유저가 존재하지 않습니다."), .userNotFound),
            (.badRequest(message: "이미 존재하는 닉네임이에요."), .duplicateNickname),
            (.badRequest(message: "nickname must be shorter than or equal to 10 characters"), .nicknameTooLong),
            (.forbidden(message: "탈퇴한 회원입니다."), .withdrawn),
            (.badRequest(message: "nickname should not be empty"), .emptyNickname)
        ]

        for (networkError, expectedError) in testCases {
            // When
            let result = sut.mapToUserError(networkError)

            // Then
            #expect(result == expectedError)
        }
    }

    @Test("인증 토큰 없음 에러를 unknown으로 변환해야 한다")
    func 인증_토큰_없음_에러를_unknown으로_변환해야_한다() {
        // Given
        let sut = UserErrorMapper()
        let networkError = NetworkError.unauthorized(message: "Unauthorized")

        // When
        let result = sut.mapToUserError(networkError)

        // Then
        #expect(result == .unknown)
    }

    @Test("취소 에러를 cancelled로 변환해야 한다")
    func 취소_에러를_cancelled로_변환해야_한다() {
        // Given
        let sut = UserErrorMapper()

        // When & Then
        #expect(sut.mapToUserError(CancellationError()) == .cancelled)
        #expect(sut.mapToUserError(URLError(.cancelled)) == .cancelled)
        #expect(sut.mapToUserError(NetworkError.unknown(URLError(.cancelled))) == .cancelled)
        #expect(sut.mapToUserError(NetworkError.noConnection(URLError(.cancelled))) == .cancelled)
    }

    @Test("NetworkError가 아닌 에러를 unknown으로 변환해야 한다")
    func NetworkError가_아닌_에러를_unknown으로_변환해야_한다() {
        // Given
        struct SomeError: Error {}
        let sut = UserErrorMapper()
        let error = SomeError()

        // When
        let result = sut.mapToUserError(error)

        // Then
        #expect(result == .unknown)
    }
}
