//
//  FetchConcertListDTOTests.swift
//  LivithNetworkTests
//
//  Created by 김진웅 on 5/1/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation
import Testing

@testable import LivithNetwork

struct FetchConcertListDTOTests {
    @Test("검색 콘서트 응답은 optional 표시 필드가 null이어도 디코딩해야 한다")
    func 검색_콘서트_응답은_optional_표시_필드가_null이어도_디코딩해야_한다() throws {
        // Given
        let json = """
        {
            "data": [
                {
                    "id": 1641,
                    "code": null,
                    "title": null,
                    "startDate": null,
                    "endDate": null,
                    "status": "UPCOMING",
                    "poster": null,
                    "artist": "Freedom Call (프리덤 콜)",
                    "daysLeft": null,
                    "ticketSite": null,
                    "ticketUrl": null,
                    "venue": null,
                    "introduction": "첫 단독 내한 공연",
                    "label": null
                }
            ],
            "cursor": null,
            "totalCount": 1
        }
        """.data(using: .utf8)!

        // When
        let result = try JSONDecoder().decode(DTO.Response.FetchFilterSearchResult.self, from: json)

        // Then
        let concert = try #require(result.data.first)
        #expect(result.cursor == nil)
        #expect(result.totalCount == 1)
        #expect(concert.id == 1641)
        #expect(concert.code == nil)
        #expect(concert.title == nil)
        #expect(concert.startDate == nil)
        #expect(concert.endDate == nil)
        #expect(concert.posterURL == nil)
        #expect(concert.daysLeft == nil)
        #expect(concert.ticketSite == nil)
        #expect(concert.ticketURL == nil)
        #expect(concert.venue == nil)
        #expect(concert.label == nil)
    }

    @Test("콘서트 목록 조회 endpoint는 GET /concerts와 query를 생성해야 한다")
    func 콘서트_목록_조회_endpoint는_GET_concerts와_query를_생성해야_한다() throws {
        // Given
        let endpoint = SearchEndpoint.fetchConcertList(cursor: 20, size: 12)
        let query = try #require(endpoint.query)

        // Then
        #expect(endpoint.path == "/concerts")
        #expect(endpoint.method == .get)
        #expect(endpoint.body == nil)
        #expect(!endpoint.requiresInterceptor)
        #expect(query["cursor"] as? Int == 20)
        #expect(query["size"] as? Int == 12)
    }

    @Test("필터 검색 endpoint는 GET /search/concerts와 query를 생성해야 한다")
    func 필터_검색_endpoint는_GET_search_concerts와_query를_생성해야_한다() throws {
        // Given
        let endpoint = SearchEndpoint.fetchFilterSearchResult(
            genre: ["ALL"],
            sort: nil,
            status: ["ONGOING", "UPCOMING"],
            keyword: "freedom",
            cursor: 1641,
            size: 12
        )
        let query = try #require(endpoint.query)

        // Then
        #expect(endpoint.path == "/search/concerts")
        #expect(endpoint.method == .get)
        #expect(endpoint.body == nil)
        #expect(!endpoint.requiresInterceptor)
        #expect(query["genre"] as? [String] == ["ALL"])
        #expect(query["sort"] == nil)
        #expect(query["status"] as? [String] == ["ONGOING", "UPCOMING"])
        #expect(query["keyword"] as? String == "freedom")
        #expect(query["cursor"] as? Int == 1641)
        #expect(query["size"] as? Int == 12)
    }

    @Test("콘서트 목록 응답은 optional 필드와 cursor null을 디코딩해야 한다")
    func 콘서트_목록_응답은_optional_필드와_cursor_null을_디코딩해야_한다() throws {
        // Given
        let json = """
        {
            "data": [
                {
                    "id": 1641,
                    "code": null,
                    "title": null,
                    "startDate": null,
                    "endDate": null,
                    "status": "UPCOMING",
                    "poster": null,
                    "artist": "Freedom Call (프리덤 콜)",
                    "daysLeft": null,
                    "ticketSite": null,
                    "ticketUrl": null,
                    "venue": null,
                    "introduction": "첫 단독 내한 공연",
                    "label": null
                }
            ],
            "cursor": null
        }
        """.data(using: .utf8)!

        // When
        let result = try JSONDecoder().decode(DTO.Response.FetchConcertList.self, from: json)

        // Then
        let concert = try #require(result.data.first)
        #expect(result.cursor == nil)
        #expect(concert.id == 1641)
        #expect(concert.code == nil)
        #expect(concert.title == nil)
        #expect(concert.startDate == nil)
        #expect(concert.endDate == nil)
        #expect(concert.posterURL == nil)
        #expect(concert.daysLeft == nil)
        #expect(concert.ticketSite == nil)
        #expect(concert.ticketURL == nil)
        #expect(concert.venue == nil)
        #expect(concert.label == nil)
    }
}
