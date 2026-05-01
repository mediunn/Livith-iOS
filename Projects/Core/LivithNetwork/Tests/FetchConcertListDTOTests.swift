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
