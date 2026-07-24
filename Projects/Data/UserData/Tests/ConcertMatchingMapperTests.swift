//
//  ConcertMatchingMapperTests.swift
//  UserDataTests
//
//  Created by youz2me on 7/20/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation
import Testing

import Domain
import LivithNetworking
@testable import UserData

@Suite("콘서트 매칭 매퍼 테스트")
struct ConcertMatchingMapperTests {
    @Test("CreateExtractionJob 응답의 콘서트 목록이 Concert로 변환되어야 한다")
    func createExtractionJob_응답의_콘서트_목록이_Concert로_변환되어야_한다() throws {
        // Given
        let sut = ConcertMatchingMapper()
        let json = """
        {
            "result": "MATCHED",
            "concerts": [
                {
                    "id": 1641,
                    "code": "PF284586",
                    "title": "FREEDOM CALL LIVE IN SEOUL",
                    "startDate": "2026.05.02",
                    "endDate": "2026.05.03",
                    "status": "UPCOMING",
                    "poster": "http://www.kopis.or.kr/upload/pfmPoster/PF_PF284586_260206_104431.gif",
                    "artist": "Freedom Call (프리덤 콜)",
                    "daysLeft": null,
                    "ticketSite": "NOL 티켓",
                    "ticketUrl": "https://tickets.interpark.com/goods/26001555",
                    "venue": "JS 아트홀 (JS ART HALL)",
                    "introduction": "독일 파워 메탈 밴드 Freedom Call의 내한 공연!",
                    "label": null
                }
            ]
        }
        """
        let dto = try JSONDecoder().decode(DTO.Response.CreateExtractionJob.self, from: Data(json.utf8))

        // When
        let concertList = sut.toDomain(from: dto)

        // Then
        let concert = try #require(concertList.first)
        #expect(concertList.count == 1)
        #expect(concert.id == 1641)
        #expect(concert.title == "FREEDOM CALL LIVE IN SEOUL")
        #expect(concert.artist == "Freedom Call (프리덤 콜)")
        #expect(concert.status == .upcoming)
        #expect(concert.daysLeft == nil)
        #expect(concert.startDate != nil)
        #expect(concert.endDate != nil)
        #expect(concert.posterURL == URL(string: "http://www.kopis.or.kr/upload/pfmPoster/PF_PF284586_260206_104431.gif"))
        #expect(concert.venue == "JS 아트홀 (JS ART HALL)")
        #expect(concert.ticketingOffice == "NOL 티켓")
        #expect(concert.ticketingOfficeURL == URL(string: "https://tickets.interpark.com/goods/26001555"))
        #expect(concert.introduction == "독일 파워 메탈 밴드 Freedom Call의 내한 공연!")
        #expect(concert.label == nil)
    }

    @Test("null 허용 필드가 비어 있는 콘서트도 목록에서 제외되지 않아야 한다")
    func null_허용_필드가_비어_있는_콘서트도_목록에서_제외되지_않아야_한다() throws {
        // Given
        let sut = ConcertMatchingMapper()
        let json = """
        {
            "result": "MATCHED",
            "concerts": [
                {
                    "id": 7,
                    "code": null,
                    "title": null,
                    "startDate": null,
                    "endDate": null,
                    "status": "UPCOMING",
                    "poster": null,
                    "artist": "아티스트",
                    "daysLeft": null,
                    "ticketSite": null,
                    "ticketUrl": null,
                    "venue": null,
                    "introduction": "소개",
                    "label": null
                }
            ]
        }
        """
        let dto = try JSONDecoder().decode(DTO.Response.CreateExtractionJob.self, from: Data(json.utf8))

        // When
        let concertList = sut.toDomain(from: dto)

        // Then
        let concert = try #require(concertList.first)
        #expect(concertList.count == 1)
        #expect(concert.id == 7)
        #expect(concert.title == nil)
        #expect(concert.startDate == nil)
        #expect(concert.endDate == nil)
        #expect(concert.posterURL == nil)
        #expect(concert.venue == nil)
        #expect(concert.daysLeft == nil)
    }

    @Test("status가 유효하지 않은 콘서트는 변환 결과에서 제외되어야 한다")
    func status가_유효하지_않은_콘서트는_변환_결과에서_제외되어야_한다() throws {
        // Given
        let sut = ConcertMatchingMapper()
        let json = """
        {
            "result": "MATCHED",
            "concerts": [
                {
                    "id": 1,
                    "code": null,
                    "title": "유효한 콘서트",
                    "startDate": "2026.05.02",
                    "endDate": "2026.05.03",
                    "status": "UPCOMING",
                    "poster": null,
                    "artist": "아티스트",
                    "daysLeft": 10,
                    "ticketSite": null,
                    "ticketUrl": null,
                    "venue": null,
                    "introduction": "소개",
                    "label": null
                },
                {
                    "id": 2,
                    "code": null,
                    "title": "상태가 유효하지 않은 콘서트",
                    "startDate": "2026.05.02",
                    "endDate": "2026.05.03",
                    "status": "INVALID_STATUS",
                    "poster": null,
                    "artist": "아티스트",
                    "daysLeft": 10,
                    "ticketSite": null,
                    "ticketUrl": null,
                    "venue": null,
                    "introduction": "소개",
                    "label": null
                }
            ]
        }
        """
        let dto = try JSONDecoder().decode(DTO.Response.CreateExtractionJob.self, from: Data(json.utf8))

        // When
        let concertList = sut.toDomain(from: dto)

        // Then
        #expect(concertList.count == 1)
        #expect(concertList.first?.id == 1)
    }
}
