//
//  UserMapperTests.swift
//  DataTests
//
//  Created by 김진웅 on 2026/01/22.
//  Copyright © 2026 Livith. All rights reserved.
//

import XCTest

import LivithNetwork
import Domain
@testable import UserData

final class UserMapperTests: XCTestCase {
    private var sut: UserMapper!
    
    override func setUp() {
        super.setUp()
        sut = UserMapper()
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    func test_UpdateUserNickname_모든_필드가_있을때_User로_변환해야_한다() throws {
        // Given
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
        XCTAssertEqual(result.id, 1)
        XCTAssertEqual(result.interestConcertID, 100)
        XCTAssertEqual(result.provider, "kakao")
        XCTAssertEqual(result.providerID, "4484239560")
        XCTAssertEqual(result.email, "test@example.com")
        XCTAssertEqual(result.nickname, "라이빗")
        XCTAssertTrue(result.authority.marketingConsent)
    }
    
    func test_UpdateUserNickname_Optional필드가_null일때_User로_변환해야_한다() throws {
        // Given
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
        XCTAssertEqual(result.id, 1)
        XCTAssertNil(result.interestConcertID)
        XCTAssertEqual(result.provider, "kakao")
        XCTAssertEqual(result.providerID, "4484239560")
        XCTAssertNil(result.email)
        XCTAssertEqual(result.nickname, "라이빗")
        XCTAssertFalse(result.authority.marketingConsent)
    }

    func test_FetchUserInfo_모든_필드가_있을때_User로_변환해야_한다() throws {
        // Given
        let json = """
        {
            "id": 42,
            "interestConcertId": 200,
            "provider": "apple",
            "providerId": "001234.abcd1234",
            "email": "user@icloud.com",
            "nickname": "테스트유저",
            "marketingConsent": true
        }
        """.data(using: .utf8)!

        let dto = try JSONDecoder().decode(DTO.Response.FetchUserInfo.self, from: json)

        // When
        let result = sut.toDomain(from: dto)

        // Then
        XCTAssertEqual(result.id, 42)
        XCTAssertEqual(result.interestConcertID, 200)
        XCTAssertEqual(result.provider, "apple")
        XCTAssertEqual(result.providerID, "001234.abcd1234")
        XCTAssertEqual(result.email, "user@icloud.com")
        XCTAssertEqual(result.nickname, "테스트유저")
        XCTAssertTrue(result.authority.marketingConsent)
    }

    func test_FetchUserInfo_Optional필드가_null일때_User로_변환해야_한다() throws {
        // Given
        let json = """
        {
            "id": 99,
            "interestConcertId": null,
            "provider": "kakao",
            "providerId": "9876543210",
            "email": null,
            "nickname": "익명",
            "marketingConsent": false
        }
        """.data(using: .utf8)!

        let dto = try JSONDecoder().decode(DTO.Response.FetchUserInfo.self, from: json)

        // When
        let result = sut.toDomain(from: dto)

        // Then
        XCTAssertEqual(result.id, 99)
        XCTAssertNil(result.interestConcertID)
        XCTAssertEqual(result.provider, "kakao")
        XCTAssertEqual(result.providerID, "9876543210")
        XCTAssertNil(result.email)
        XCTAssertEqual(result.nickname, "익명")
        XCTAssertFalse(result.authority.marketingConsent)
    }

    func test_FetchUserInterestConcert_모든_필드가_있을때_Concert로_변환해야_한다() throws {
        // Given
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
        let result = try XCTUnwrap(sut.toDomain(from: dto))

        // Then
        XCTAssertEqual(result.id, 8)
        XCTAssertEqual(result.title, "제이크 밀러 첫 단독 내한공연 JAKE MILLER BALANCE TOUR")
        XCTAssertEqual(result.artist, "JAKE MILLER (제이크 밀러)")
        XCTAssertEqual(result.status, .completed)
        XCTAssertEqual(result.daysLeft, -16)
        XCTAssertEqual(result.posterURL.absoluteString, "http://www.kopis.or.kr/upload/pfmPoster/PF_PF268438_250703_114113.gif")
        XCTAssertEqual(result.venue, "무신사 개러지")
        XCTAssertEqual(result.ticketingOffice, "NOL 티켓")
        XCTAssertEqual(result.ticketingOfficeURL?.absoluteString, "https://tickets.interpark.com/goods/25009244")
        XCTAssertEqual(result.introduction, "데뷔 10년 만에 드디어 한국 상륙! 제이크 밀러, 첫 단독 내한 'BALANCE TOUR'로 잊지 못할 밤을 선사!")
        XCTAssertEqual(result.label, "첫 단독 내한 콘서트")
    }

    func test_FetchUserInterestConcert_Optional필드가_null일때_Concert로_변환해야_한다() throws {
        // Given
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
        let result = try XCTUnwrap(sut.toDomain(from: dto))

        // Then
        XCTAssertEqual(result.id, 2)
        XCTAssertEqual(result.title, "버스커버스커 공연")
        XCTAssertEqual(result.artist, "버스커버스커")
        XCTAssertEqual(result.status, .ongoing)
        XCTAssertEqual(result.daysLeft, 0)
        XCTAssertEqual(result.posterURL.absoluteString, "https://example.com/busker.jpg")
        XCTAssertEqual(result.venue, "홍대 놀이터")
        XCTAssertNil(result.ticketingOffice)
        XCTAssertNil(result.ticketingOfficeURL)
        XCTAssertEqual(result.introduction, "무료 게릴라 공연")
        XCTAssertNil(result.label)
    }

    func test_UpdateUserInterestConcert_모든_필드가_있을때_Concert로_변환해야_한다() throws {
        // Given
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
        let result = try XCTUnwrap(sut.toDomain(from: dto))

        // Then
        XCTAssertEqual(result.id, 8)
        XCTAssertEqual(result.title, "제이크 밀러 첫 단독 내한공연 JAKE MILLER BALANCE TOUR")
        XCTAssertEqual(result.artist, "JAKE MILLER (제이크 밀러)")
        XCTAssertEqual(result.status, .completed)
        XCTAssertEqual(result.daysLeft, 0)  // DTO에 daysLeft가 없으므로 항상 0
        XCTAssertEqual(result.posterURL.absoluteString, "http://www.kopis.or.kr/upload/pfmPoster/PF_PF268438_250703_114113.gif")
        XCTAssertEqual(result.venue, "무신사 개러지")
        XCTAssertEqual(result.ticketingOffice, "NOL 티켓")
        XCTAssertEqual(result.ticketingOfficeURL?.absoluteString, "https://tickets.interpark.com/goods/25009244")
        XCTAssertEqual(result.introduction, "데뷔 10년 만에 드디어 한국 상륙! 제이크 밀러, 첫 단독 내한 'BALANCE TOUR'로 잊지 못할 밤을 선사!")
        XCTAssertEqual(result.label, "첫 단독 내한 콘서트")
    }

    func test_UpdateUserInterestConcert_Optional필드가_null일때_Concert로_변환해야_한다() throws {
        // Given
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
        let result = try XCTUnwrap(sut.toDomain(from: dto))

        // Then
        XCTAssertEqual(result.id, 10)
        XCTAssertEqual(result.title, "무료 버스킹 공연")
        XCTAssertEqual(result.artist, "인디 밴드")
        XCTAssertEqual(result.status, .upcoming)
        XCTAssertEqual(result.daysLeft, 0)
        XCTAssertEqual(result.posterURL.absoluteString, "https://example.com/busking.jpg")
        XCTAssertEqual(result.venue, "신촌 연세로")
        XCTAssertNil(result.ticketingOffice)
        XCTAssertNil(result.ticketingOfficeURL)
        XCTAssertEqual(result.introduction, "무료로 즐기는 버스킹 공연")
        XCTAssertNil(result.label)
    }
}

final class UserErrorMapperTests: XCTestCase {
    private var sut: UserErrorMapper!
    
    override func setUp() {
        super.setUp()
        sut = UserErrorMapper()
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    // MARK: - 기본 네트워크 에러 변환 테스트
    
    func test_네트워크_연결_없음_에러는_noConnection으로_변환되어야_한다() {
        // Given
        let networkError = NetworkError.noConnection(NSError(domain: "", code: -1))
        
        // When
        let result = sut.mapToUserError(networkError)
        
        // Then
        XCTAssertEqual(result, .noConnection)
    }
    
    func test_서버_에러는_serverError로_변환되어야_한다() {
        // Given
        let networkError = NetworkError.serverError(message: nil)
        
        // When
        let result = sut.mapToUserError(networkError)
        
        // Then
        XCTAssertEqual(result, .serverError)
    }
    
    func test_잘못된_요청_관련_에러들은_invalidResponse로_변환되어야_한다() {
        // Given
        let errors: [NetworkError] = [
            .noData,
            .decodingFailed(NSError(domain: "", code: -1)),
            .invalidURL,
            .invalidRequest,
            .invalidResponse,
            .clientError(statusCode: 400, message: nil)
        ]
        
        errors.forEach { error in
            // When
            let result = sut.mapToUserError(error)
            
            // Then
            XCTAssertEqual(result, .invalidResponse, "Failed for error: \(error)")
        }
    }
    
    // MARK: - 메시지 기반 에러 변환 테스트
    
    func test_유저_없음_에러_메시지는_userNotFound로_변환되어야_한다() {
        // Given - 404 Not Found: "해당 유저가 존재하지 않습니다."
        let networkError = NetworkError.notFound(message: "해당 유저가 존재하지 않습니다.")
        
        // When
        let result = sut.mapToUserError(networkError)
        
        // Then
        XCTAssertEqual(result, .userNotFound)
    }
    
    func test_중복_닉네임_에러_메시지는_duplicateNickname으로_변환되어야_한다() {
        // Given - 400 Bad Request: "이미 존재하는 닉네임이에요."
        let networkError = NetworkError.badRequest(message: "이미 존재하는 닉네임이에요.")
        
        // When
        let result = sut.mapToUserError(networkError)
        
        // Then
        XCTAssertEqual(result, .duplicateNickname)
    }
    
    func test_닉네임_길이_초과_에러_메시지는_nicknameTooLong으로_변환되어야_한다() {
        // Given - 400 Bad Request: "nickname must be shorter than or equal to 10 characters"
        let networkError = NetworkError.badRequest(message: "nickname must be shorter than or equal to 10 characters")
        
        // When
        let result = sut.mapToUserError(networkError)
        
        // Then
        XCTAssertEqual(result, .nicknameTooLong)
    }
    
    func test_탈퇴한_회원_에러_메시지는_withdrawn으로_변환되어야_한다() {
        // Given - 403 Forbidden: "탈퇴한 회원입니다."
        let networkError = NetworkError.forbidden(message: "탈퇴한 회원입니다.")
        
        // When
        let result = sut.mapToUserError(networkError)
        
        // Then
        XCTAssertEqual(result, .withdrawn)
    }
    
    func test_빈_닉네임_에러_메시지는_emptyNickname으로_변환되어야_한다() {
        // Given - 400 Bad Request: "nickname should not be empty"
        let networkError = NetworkError.badRequest(message: "nickname should not be empty")
        
        // When
        let result = sut.mapToUserError(networkError)
        
        // Then
        XCTAssertEqual(result, .emptyNickname)
    }
    
    func test_인증_토큰_없음_에러는_unknown으로_변환되어야_한다() {
        // Given - 401 Unauthorized: "Unauthorized"
        let networkError = NetworkError.unauthorized(message: "Unauthorized")
        
        // When
        let result = sut.mapToUserError(networkError)
        
        // Then
        XCTAssertEqual(result, .unknown)
    }
    
    // MARK: - 취소 에러 변환 테스트
    
    func test_취소_에러는_cancelled로_변환되어야_한다() {
        // Given
        let cancellationError = CancellationError()
        let urlCancelledError = URLError(.cancelled)
        let networkCancelledError = NetworkError.unknown(URLError(.cancelled))
        let networkNoConnectionCancelledError = NetworkError.noConnection(URLError(.cancelled))
        
        // When & Then
        XCTAssertEqual(sut.mapToUserError(cancellationError), .cancelled)
        XCTAssertEqual(sut.mapToUserError(urlCancelledError), .cancelled)
        XCTAssertEqual(sut.mapToUserError(networkCancelledError), .cancelled)
        XCTAssertEqual(sut.mapToUserError(networkNoConnectionCancelledError), .cancelled)
    }
    
    // MARK: - 기타 에러 변환 테스트
    
    func test_NetworkError가_아닌_에러는_unknown으로_변환되어야_한다() {
        // Given
        struct SomeError: Error {}
        let error = SomeError()
        
        // When
        let result = sut.mapToUserError(error)
        
        // Then
        XCTAssertEqual(result, .unknown)
    }
    
    func test_메시지_기반_에러들이_올바르게_변환되어야_한다() {
        // Given
        let testCases: [(NetworkError, UserError)] = [
            (.notFound(message: "해당 유저가 존재하지 않습니다."), .userNotFound),
            (.badRequest(message: "이미 존재하는 닉네임이에요."), .duplicateNickname),
            (.badRequest(message: "nickname must be shorter than or equal to 10 characters"), .nicknameTooLong),
            (.forbidden(message: "탈퇴한 회원입니다."), .withdrawn),
            (.badRequest(message: "nickname should not be empty"), .emptyNickname)
        ]
        
        testCases.forEach { networkError, expectedError in
            // When
            let result = sut.mapToUserError(networkError)
            
            // Then
            XCTAssertEqual(result, expectedError, "Failed for error: \(networkError)")
        }
    }
}
