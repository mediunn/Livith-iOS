//
//  UserRepositoryImplTests.swift
//  UserDataTests
//
//  Created by 김진웅 on 4/29/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

import Domain
import LivithNetwork
import Persistence
import Testing
@testable import UserData

@Suite("유저 Repository 테스트")
struct UserRepositoryImplTests {
    @Test("관심 콘서트 목록 조회 조건을 API request로 변환해야 한다")
    func 관심_콘서트_목록_조회_조건을_API_request로_변환해야_한다() async throws {
        // Given
        var capturedRequest: DTO.Request.FetchInterestConcertList?
        let sut = makeSUT { request in
            capturedRequest = request
            return try decodeInterestConcertResponse(from: emptyPageJSON)
        }
        let cursorDate = try #require(date("2025.09.27"))
        let query = InterestConcertListQuery(
            sort: .ticketing,
            pageSize: 12,
            cursor: InterestConcertPageCursor(date: cursorDate, id: 8)
        )

        // When
        let result = try await sut.fetchInterestedConcertList(query: query)

        // Then
        let request = try #require(capturedRequest)
        #expect(result.concertList.isEmpty)
        #expect(result.nextCursor == nil)
        #expect(request.sort == .ticketing)
        #expect(request.size == 12)
        #expect(request.cursorDate == "2025.09.27")
        #expect(request.cursorID == 8)
    }

    @Test("관심 콘서트 목록 data가 null이면 빈 페이지로 변환해야 한다")
    func 관심_콘서트_목록_data가_null이면_빈_페이지로_변환해야_한다() async throws {
        // Given
        let sut = makeSUT { _ in
            throw NetworkError.noData
        }

        // When
        let result = try await sut.fetchInterestedConcertList(query: .init())

        // Then
        #expect(result.concertList.isEmpty)
        #expect(result.nextCursor == nil)
    }

    @Test("첫 페이지 관심 콘서트 목록은 캐시를 우선 사용해야 한다")
    func 첫_페이지_관심_콘서트_목록은_캐시를_우선_사용해야_한다() async throws {
        // Given
        var requestCount = 0
        let sut = makeSUT { _ in
            requestCount += 1
            return try decodeInterestConcertResponse(from: oneItemPageJSON)
        }

        // When
        let firstResult = try await sut.fetchInterestedConcertList(query: .init())
        let secondResult = try await sut.fetchInterestedConcertList(query: .init())

        // Then
        #expect(requestCount == 1)
        #expect(firstResult == secondResult)
        #expect(secondResult.concertList.map(\.id) == [8])
    }

    @Test("첫 페이지 query가 다르면 캐시를 재사용하지 않아야 한다")
    func 첫_페이지_query가_다르면_캐시를_재사용하지_않아야_한다() async throws {
        // Given
        var requestCount = 0
        let sut = makeSUT { _ in
            requestCount += 1
            return try decodeInterestConcertResponse(
                from: requestCount == 1 ? oneItemPageJSON : emptyPageJSON
            )
        }

        // When
        let firstResult = try await sut.fetchInterestedConcertList(query: .init())
        let secondResult = try await sut.fetchInterestedConcertList(
            query: InterestConcertListQuery(sort: .ticketing, pageSize: 12)
        )

        // Then
        #expect(requestCount == 2)
        #expect(firstResult.concertList.map(\.id) == [8])
        #expect(secondResult.concertList.isEmpty)
    }

    @Test("관심 콘서트를 변경하면 첫 페이지 캐시를 무효화해야 한다")
    func 관심_콘서트를_변경하면_첫_페이지_캐시를_무효화해야_한다() async throws {
        // Given
        var requestCount = 0
        let sut = makeSUT(
            fetchInterestConcertListRequest: { _ in
                requestCount += 1
                return try decodeInterestConcertResponse(
                    from: requestCount == 1 ? oneItemPageJSON : emptyPageJSON
                )
            },
            updateInterestConcertRequest: { _ in
                try decodeUpdateInterestConcertResponse()
            }
        )

        // When
        let firstResult = try await sut.fetchInterestedConcertList(query: .init())
        _ = try await sut.updateInterestedConcert(8)
        let secondResult = try await sut.fetchInterestedConcertList(query: .init())

        // Then
        #expect(requestCount == 2)
        #expect(firstResult.concertList.map(\.id) == [8])
        #expect(secondResult.concertList.isEmpty)
    }

    @Test("관심 콘서트 변경 응답 매핑이 실패해도 첫 페이지 캐시를 무효화해야 한다")
    func 관심_콘서트_변경_응답_매핑이_실패해도_첫_페이지_캐시를_무효화해야_한다() async throws {
        // Given
        var requestCount = 0
        let sut = makeSUT(
            fetchInterestConcertListRequest: { _ in
                requestCount += 1
                return try decodeInterestConcertResponse(
                    from: requestCount == 1 ? oneItemPageJSON : emptyPageJSON
                )
            },
            updateInterestConcertRequest: { _ in
                try decodeInvalidUpdateInterestConcertResponse()
            }
        )

        // When
        let firstResult = try await sut.fetchInterestedConcertList(query: .init())
        do {
            _ = try await sut.updateInterestedConcert(8)
            Issue.record("관심 콘서트 변경 응답 매핑 실패는 invalidResponse를 throw해야 합니다.")
        } catch UserError.invalidResponse {
        } catch {
            Issue.record("예상하지 못한 에러가 발생했습니다: \(error)")
        }
        let secondResult = try await sut.fetchInterestedConcertList(query: .init())

        // Then
        #expect(requestCount == 2)
        #expect(firstResult.concertList.map(\.id) == [8])
        #expect(secondResult.concertList.isEmpty)
    }

    @Test("관심 콘서트를 삭제하면 첫 페이지 캐시를 무효화해야 한다")
    func 관심_콘서트를_삭제하면_첫_페이지_캐시를_무효화해야_한다() async throws {
        // Given
        var requestCount = 0
        let sut = makeSUT(
            fetchInterestConcertListRequest: { _ in
                requestCount += 1
                return try decodeInterestConcertResponse(
                    from: requestCount == 1 ? oneItemPageJSON : emptyPageJSON
                )
            },
            deleteInterestConcertRequest: {
                try decodeEmptyResponse()
            }
        )

        // When
        let firstResult = try await sut.fetchInterestedConcertList(query: .init())
        try await sut.deleteInterestedConcert()
        let secondResult = try await sut.fetchInterestedConcertList(query: .init())

        // Then
        #expect(requestCount == 2)
        #expect(firstResult.concertList.map(\.id) == [8])
        #expect(secondResult.concertList.isEmpty)
    }
}

private extension UserRepositoryImplTests {
    func makeSUT(
        fetchInterestConcertListRequest: @escaping (DTO.Request.FetchInterestConcertList) async throws -> DTO.Response.FetchUserInterestConcert,
        updateInterestConcertRequest: @escaping (Int) async throws -> DTO.Response.UpdateUserInterestConcert = { _ in
            throw NetworkError.invalidRequest
        },
        deleteInterestConcertRequest: @escaping () async throws -> DTO.Response.EmptyResponse = {
            throw NetworkError.invalidRequest
        }
    ) -> UserRepositoryImpl {
        let suiteName = "UserRepositoryImplTests.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suiteName) ?? .standard
        defaults.removePersistentDomain(forName: suiteName)
        return UserRepositoryImpl(
            userdefaultsStorage: UserDefaultsStorage(defaults: defaults),
            fetchInterestConcertListRequest: fetchInterestConcertListRequest,
            updateInterestConcertRequest: updateInterestConcertRequest,
            deleteInterestConcertRequest: deleteInterestConcertRequest
        )
    }

    func date(_ string: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(identifier: "Asia/Seoul")
        return formatter.date(from: string)
    }

    func decodeInterestConcertResponse(from json: String) throws -> DTO.Response.FetchUserInterestConcert {
        let data = try #require(json.data(using: .utf8))
        return try JSONDecoder().decode(DTO.Response.FetchUserInterestConcert.self, from: data)
    }

    func decodeUpdateInterestConcertResponse() throws -> DTO.Response.UpdateUserInterestConcert {
        let data = try #require(updateInterestConcertJSON.data(using: .utf8))
        return try JSONDecoder().decode(DTO.Response.UpdateUserInterestConcert.self, from: data)
    }

    func decodeInvalidUpdateInterestConcertResponse() throws -> DTO.Response.UpdateUserInterestConcert {
        let data = try #require(invalidUpdateInterestConcertJSON.data(using: .utf8))
        return try JSONDecoder().decode(DTO.Response.UpdateUserInterestConcert.self, from: data)
    }

    func decodeEmptyResponse() throws -> DTO.Response.EmptyResponse {
        let data = try #require("{}".data(using: .utf8))
        return try JSONDecoder().decode(DTO.Response.EmptyResponse.self, from: data)
    }

    var emptyPageJSON: String {
        """
        {
            "data": [],
            "cursor": null
        }
        """
    }

    var oneItemPageJSON: String {
        """
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
                    "introduction": "데뷔 10년 만에 드디어 한국 상륙!",
                    "label": "첫 단독 내한 콘서트",
                    "preSaleDate": "2025-06-15T12:00:00.000Z",
                    "generalSaleDate": "2025-06-20T12:00:00.000Z"
                }
            ],
            "cursor": null
        }
        """
    }

    var updateInterestConcertJSON: String {
        """
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
            "introduction": "데뷔 10년 만에 드디어 한국 상륙!",
            "label": "첫 단독 내한 콘서트"
        }
        """
    }

    var invalidUpdateInterestConcertJSON: String {
        """
        {
            "id": 8,
            "code": "PF268438",
            "title": "제이크 밀러 첫 단독 내한공연 JAKE MILLER BALANCE TOUR",
            "startDate": "2025.09.27",
            "endDate": "2025.09.27",
            "status": "INVALID",
            "poster": "http://www.kopis.or.kr/upload/pfmPoster/PF_PF268438_250703_114113.gif",
            "artist": "JAKE MILLER (제이크 밀러)",
            "ticketSite": "NOL 티켓",
            "ticketUrl": "https://tickets.interpark.com/goods/25009244",
            "venue": "무신사 개러지",
            "introduction": "데뷔 10년 만에 드디어 한국 상륙!",
            "label": "첫 단독 내한 콘서트"
        }
        """
    }
}
