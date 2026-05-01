//
//  ConcertListMapperTests.swift
//  ConcertDataTests
//
//  Created by 김진웅 on 5/1/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation
import Testing

import Domain
import LivithNetwork
@testable import ConcertData

struct ConcertListMapperTests {
    @Test("검색 콘서트 응답의 optional 표시 필드가 nil이어도 콘서트를 보존해야 한다")
    func 검색_콘서트_응답의_optional_표시_필드가_nil이어도_콘서트를_보존해야_한다() throws {
        // Given
        let sut = ConcertMapper()
        let json = """
        {
            "data": [
                {
                    "id": 1641,
                    "status": "UPCOMING",
                    "artist": "Freedom Call (프리덤 콜)",
                    "introduction": "첫 단독 내한 공연"
                }
            ],
            "cursor": 1641,
            "totalCount": 1
        }
        """.data(using: .utf8)!
        let dto = try JSONDecoder().decode(DTO.Response.FetchFilterSearchResult.self, from: json)

        // When
        let result = dto.data.compactMap { sut.toDomain(from: $0) }
        let concert = try #require(result.first)

        // Then
        #expect(result.count == 1)
        #expect(concert.id == 1641)
        #expect(concert.status == .upcoming)
        #expect(concert.artist == "Freedom Call (프리덤 콜)")
        #expect(concert.title == nil)
        #expect(concert.startDate == nil)
        #expect(concert.endDate == nil)
        #expect(concert.posterURL == nil)
        #expect(concert.daysLeft == nil)
        #expect(concert.venue == nil)
        #expect(concert.introduction == "첫 단독 내한 공연")
    }

    @Test("콘서트 목록 응답의 optional 표시 필드가 nil이어도 콘서트를 보존해야 한다")
    func 콘서트_목록_응답의_optional_표시_필드가_nil이어도_콘서트를_보존해야_한다() throws {
        // Given
        let sut = ConcertMapper()
        let json = """
        {
            "data": [
                {
                    "id": 1641,
                    "status": "UPCOMING",
                    "artist": "Freedom Call (프리덤 콜)",
                    "introduction": "첫 단독 내한 공연"
                }
            ],
            "cursor": 1641
        }
        """.data(using: .utf8)!
        let dto = try JSONDecoder().decode(DTO.Response.FetchConcertList.self, from: json)

        // When
        let result = sut.toConcertListResult(from: dto)
        let concert = try #require(result.items.first)

        // Then
        #expect(result.nextToken != nil)
        #expect(result.items.count == 1)
        #expect(concert.id == 1641)
        #expect(concert.status == .upcoming)
        #expect(concert.artist == "Freedom Call (프리덤 콜)")
        #expect(concert.title == nil)
        #expect(concert.startDate == nil)
        #expect(concert.endDate == nil)
        #expect(concert.posterURL == nil)
        #expect(concert.daysLeft == nil)
        #expect(concert.venue == nil)
        #expect(concert.introduction == "첫 단독 내한 공연")
    }
}
