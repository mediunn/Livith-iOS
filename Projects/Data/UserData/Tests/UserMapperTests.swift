//
//  UserMapperTests.swift
//  DataTests
//
//  Created by 김진웅 on 2026/01/22.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation
import Testing

import LivithNetworking
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

    @Test("FetchUserInterestConcert 목록 응답을 ListResult로 변환해야 한다")
    func fetchUserInterestConcert_목록_응답을_ListResult로_변환해야_한다() throws {
        // Given
        let sut = UserMapper()
        let json = """
        {
            "data": [
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
                    "label": "첫 단독 내한 콘서트",
                    "preSaleDate": "2025-06-15T12:00:00.000Z",
                    "generalSaleDate": "2025-06-20T12:00:00.000Z"
                }
            ],
            "cursor": {
                "date": "2025.09.27",
                "id": 8
            }
        }
        """.data(using: .utf8)!
        let dto = try JSONDecoder().decode(DTO.Response.FetchUserInterestConcert.self, from: json)

        // When
        let result = sut.toDomain(from: dto)
        let interestConcert = try #require(result.items.first)
        let concert = interestConcert.concert
        let nextToken = try #require(result.nextToken as? InterestConcertListNextToken)

        // Then
        #expect(result.items.count == 1)
        #expect(nextToken.id == 8)
        #expect(nextToken.cursorDate == "2025.09.27")
        #expect(concert.id == 8)
        #expect(concert.title == "제이크 밀러 첫 단독 내한공연 JAKE MILLER BALANCE TOUR")
        #expect(concert.artist == "JAKE MILLER (제이크 밀러)")
        #expect(concert.status == .completed)
        #expect(concert.daysLeft == -16)
        #expect(dateString(concert.startDate) == "2025.09.27")
        #expect(dateString(concert.endDate) == "2025.09.27")
        #expect(concert.posterURL?.absoluteString == "http://www.kopis.or.kr/upload/pfmPoster/PF_PF268438_250703_114113.gif")
        #expect(concert.venue == "무신사 개러지")
        #expect(concert.ticketingOffice == "NOL 티켓")
        #expect(concert.ticketingOfficeURL?.absoluteString == "https://tickets.interpark.com/goods/25009244")
        #expect(concert.introduction == "데뷔 10년 만에 드디어 한국 상륙! 제이크 밀러, 첫 단독 내한 'BALANCE TOUR'로 잊지 못할 밤을 선사!")
        #expect(concert.label == "첫 단독 내한 콘서트")
        #expect(dateTimeString(interestConcert.ticketingSchedule.preSaleDate) == "2025.06.15 12:00")
        #expect(dateTimeString(interestConcert.ticketingSchedule.generalSaleDate) == "2025.06.20 12:00")
    }

    @Test("FetchUserInterestConcert의 Optional 필드가 null이어도 ListResult로 변환해야 한다")
    func fetchUserInterestConcert의_Optional필드가_null이어도_ListResult로_변환해야_한다() throws {
        // Given
        let sut = UserMapper()
        let json = """
        {
            "data": [
                {
                    "id": 2,
                    "code": null,
                    "title": null,
                    "startDate": null,
                    "endDate": null,
                    "status": "ONGOING",
                    "poster": null,
                    "artist": "버스커버스커",
                    "daysLeft": null,
                    "ticketSite": null,
                    "ticketUrl": null,
                    "venue": null,
                    "introduction": "무료 게릴라 공연",
                    "label": null,
                    "preSaleDate": null,
                    "generalSaleDate": null
                }
            ],
            "cursor": null
        }
        """.data(using: .utf8)!
        let dto = try JSONDecoder().decode(DTO.Response.FetchUserInterestConcert.self, from: json)

        // When
        let result = sut.toDomain(from: dto)
        let interestConcert = try #require(result.items.first)
        let concert = interestConcert.concert

        // Then
        #expect(result.items.count == 1)
        #expect(result.nextToken == nil)
        #expect(concert.id == 2)
        #expect(concert.title == nil)
        #expect(concert.artist == "버스커버스커")
        #expect(concert.status == .ongoing)
        #expect(concert.daysLeft == nil)
        #expect(concert.startDate == nil)
        #expect(concert.endDate == nil)
        #expect(concert.posterURL == nil)
        #expect(concert.venue == nil)
        #expect(concert.ticketingOffice == nil)
        #expect(concert.ticketingOfficeURL == nil)
        #expect(concert.introduction == "무료 게릴라 공연")
        #expect(concert.label == nil)
        #expect(interestConcert.ticketingSchedule.preSaleDate == nil)
        #expect(interestConcert.ticketingSchedule.generalSaleDate == nil)
    }

    @Test("FetchUserInterestConcert의 예매 일정 파싱 실패는 해당 일정만 nil로 변환해야 한다")
    func fetchUserInterestConcert의_예매_일정_파싱_실패는_해당_일정만_nil로_변환해야_한다() throws {
        // Given
        let sut = UserMapper()
        let json = """
        {
            "data": [
                {
                    "id": 3,
                    "status": "UPCOMING",
                    "artist": "Oasis",
                    "daysLeft": 30,
                    "introduction": "Oasis Live",
                    "preSaleDate": "invalid-date",
                    "generalSaleDate": "2025-07-01T12:00:00.000Z"
                }
            ],
            "cursor": null
        }
        """.data(using: .utf8)!
        let dto = try JSONDecoder().decode(DTO.Response.FetchUserInterestConcert.self, from: json)

        // When
        let result = sut.toDomain(from: dto)
        let schedule = try #require(result.items.first?.ticketingSchedule)

        // Then
        #expect(result.items.count == 1)
        #expect(schedule.preSaleDate == nil)
        #expect(dateTimeString(schedule.generalSaleDate) == "2025.07.01 12:00")
    }

    @Test("FetchUserInterestConcert의 URL과 공연일 파싱 실패는 해당 필드만 nil로 변환해야 한다")
    func fetchUserInterestConcert의_URL과_공연일_파싱_실패는_해당_필드만_nil로_변환해야_한다() throws {
        // Given
        let sut = UserMapper()
        let json = """
        {
            "data": [
                {
                    "id": 4,
                    "title": "Invalid Field Concert",
                    "startDate": "invalid-date",
                    "endDate": "invalid-date",
                    "status": "UPCOMING",
                    "poster": "invalid-poster-url",
                    "artist": "Invalid URL Artist",
                    "daysLeft": 10,
                    "ticketSite": "Invalid Ticket",
                    "ticketUrl": "/relative-ticket-url",
                    "venue": "Invalid Venue",
                    "introduction": "Invalid URL and date fields"
                }
            ],
            "cursor": null
        }
        """.data(using: .utf8)!
        let dto = try JSONDecoder().decode(DTO.Response.FetchUserInterestConcert.self, from: json)

        // When
        let result = sut.toDomain(from: dto)
        let concert = try #require(result.items.first?.concert)

        // Then
        #expect(result.items.count == 1)
        #expect(concert.startDate == nil)
        #expect(concert.endDate == nil)
        #expect(concert.posterURL == nil)
        #expect(concert.ticketingOfficeURL == nil)
    }

    @Test("FetchUserInterestConcert의 cursor date는 원문 문자열로 보관해야 한다")
    func fetchUserInterestConcert의_cursor_date는_원문_문자열로_보관해야_한다() throws {
        // Given
        let sut = UserMapper()
        let json = """
        {
            "data": [],
            "cursor": {
                "date": "invalid-date",
                "id": 1
            }
        }
        """.data(using: .utf8)!
        let dto = try JSONDecoder().decode(DTO.Response.FetchUserInterestConcert.self, from: json)

        // When
        let result = sut.toDomain(from: dto)
        let nextToken = try #require(result.nextToken as? InterestConcertListNextToken)

        // Then
        #expect(nextToken.cursorDate == "invalid-date")
        #expect(nextToken.id == 1)
    }

    @Test("FetchUserInterestConcert의 cursor 필수 값이 없으면 nextToken을 nil로 변환해야 한다")
    func fetchUserInterestConcert의_cursor_필수_값이_없으면_nextToken을_nil로_변환해야_한다() throws {
        // Given
        let sut = UserMapper()
        let jsonList = [
            """
            {
                "data": [],
                "cursor": {
                    "date": null,
                    "id": 1
                }
            }
            """,
            """
            {
                "data": [],
                "cursor": {
                    "date": "2025.09.27",
                    "id": null
                }
            }
            """
        ]

        for json in jsonList {
            let dto = try JSONDecoder().decode(DTO.Response.FetchUserInterestConcert.self, from: json.data(using: .utf8)!)

            // When
            let result = sut.toDomain(from: dto)

            // Then
            #expect(result.nextToken == nil)
        }
    }

    @Test("FetchUserInterestConcert의 status가 유효하지 않으면 해당 항목을 제외해야 한다")
    func fetchUserInterestConcert의_status가_유효하지_않으면_해당_항목을_제외해야_한다() throws {
        // Given
        let sut = UserMapper()
        let json = """
        {
            "data": [
                {
                    "id": 1,
                    "status": "INVALID",
                    "artist": "Invalid Artist",
                    "introduction": "Invalid"
                },
                {
                    "id": 2,
                    "status": "UPCOMING",
                    "artist": "Valid Artist",
                    "introduction": "Valid"
                }
            ],
            "cursor": null
        }
        """.data(using: .utf8)!
        let dto = try JSONDecoder().decode(DTO.Response.FetchUserInterestConcert.self, from: json)

        // When
        let result = sut.toDomain(from: dto)

        // Then
        #expect(result.items.map(\.id) == [2])
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
        #expect(result.posterURL?.absoluteString == "http://www.kopis.or.kr/upload/pfmPoster/PF_PF268438_250703_114113.gif")
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
        #expect(result.posterURL?.absoluteString == "https://example.com/busking.jpg")
        #expect(result.venue == "신촌 연세로")
        #expect(result.ticketingOffice == nil)
        #expect(result.ticketingOfficeURL == nil)
        #expect(result.introduction == "무료로 즐기는 버스킹 공연")
        #expect(result.label == nil)
    }
}

private func dateString(_ date: Date?) -> String? {
    guard let date else { return nil }

    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy.MM.dd"
    formatter.locale = Locale(identifier: "en_US_POSIX")
    formatter.timeZone = TimeZone(identifier: "Asia/Seoul")
    return formatter.string(from: date)
}

private func dateTimeString(_ date: Date?) -> String? {
    guard let date else { return nil }

    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy.MM.dd HH:mm"
    formatter.locale = Locale(identifier: "en_US_POSIX")
    formatter.timeZone = TimeZone(identifier: "Asia/Seoul")
    return formatter.string(from: date)
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
        let networkError = NetworkError.serverError(statusCode: 500, message: nil)

        // When
        let result = sut.mapToUserError(networkError)

        // Then
        #expect(result == .serverError)
    }

    @Test("요청 생성 관련 에러를 invalidRequest로 변환해야 한다")
    func 요청_생성_관련_에러를_invalidRequest로_변환해야_한다() {
        // Given
        let sut = UserErrorMapper()
        let errorList: [NetworkError] = [
            .invalidURL,
            .invalidRequest
        ]

        for error in errorList {
            // When
            let result = sut.mapToUserError(error)

            // Then
            #expect(result == .invalidRequest)
        }
    }

    @Test("응답 관련 에러를 invalidResponse로 변환해야 한다")
    func 응답_관련_에러를_invalidResponse로_변환해야_한다() {
        // Given
        let sut = UserErrorMapper()
        let errorList: [NetworkError] = [
            .noData,
            .decodingFailed(NSError(domain: "", code: -1)),
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

    @Test("FetchInterestConcertToast는 needsToShow가 false이면 none 정책으로 변환해야 한다")
    func fetchInterestConcertToast는_needsToShow가_false이면_none_정책으로_변환해야_한다() throws {
        // Given
        let sut = UserMapper()
        let json = """
        {
            "needsToShow": false
        }
        """.data(using: .utf8)!
        let dto = try JSONDecoder().decode(DTO.Response.FetchInterestConcertToast.self, from: json)

        // When
        let result = sut.toDomain(from: dto)

        // Then
        #expect(result == InterestConcertCleanupPolicy.none)
    }

    @Test("FetchInterestConcertToast는 type을 관심 콘서트 정리 정책으로 변환해야 한다")
    func fetchInterestConcertToast는_type을_관심_콘서트_정리_정책으로_변환해야_한다() throws {
        // Given
        let sut = UserMapper()
        let json = """
        [
            { "needsToShow": true, "type": "CANCELED" },
            { "needsToShow": true, "type": "COMPLETED" },
            { "needsToShow": true, "type": "BOTH" }
        ]
        """.data(using: .utf8)!
        let dtoList = try JSONDecoder().decode([DTO.Response.FetchInterestConcertToast].self, from: json)

        // When
        let resultList = dtoList.map { sut.toDomain(from: $0) }

        // Then
        #expect(resultList == [.canceled, .completed, .both].map(Optional.some))
    }

    @Test("FetchInterestConcertToast는 needsToShow가 true인데 type이 없으면 변환하지 않아야 한다")
    func fetchInterestConcertToast는_needsToShow가_true인데_type이_없으면_변환하지_않아야_한다() throws {
        // Given
        let sut = UserMapper()
        let json = """
        {
            "needsToShow": true
        }
        """.data(using: .utf8)!
        let dto = try JSONDecoder().decode(DTO.Response.FetchInterestConcertToast.self, from: json)

        // When
        let result = sut.toDomain(from: dto)

        // Then
        #expect(result == nil)
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
