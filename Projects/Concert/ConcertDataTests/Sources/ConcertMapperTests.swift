//
//  ConcertMapperTests.swift
//  ConcertDataTests
//
//  Created by Youjin Lee on 12/25/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import Testing
import Foundation

@testable import ConcertData
@testable import ConcertDomain
@testable import LivithNetwork

@Suite("ConcertMapper Tests")
struct ConcertMapperTests {
    let mapper = ConcertMapper()

    // MARK: - Concert Info Tests

    @Test("콘서트 정보 매핑 성공")
    func testFetchConcertInfoMapping() {
        // Given
        let response = DTO.Response.FetchConcertInfo(
            id: 1,
            code: "CONCERT001",
            title: "2025 콘서트",
            startDate: "2025-01-01",
            endDate: "2025-01-02",
            status: "ONGOING",
            posterURL: "https://example.com/poster.jpg",
            artist: "아티스트",
            daysLeft: 10,
            ticketSite: "인터파크",
            ticketURL: "https://ticket.com",
            venue: "올림픽공원",
            introduction: "콘서트 소개",
            label: nil
        )

        // When
        let result = mapper.toDomain(from: response)

        // Then
        #expect(result != nil)
        #expect(result?.id == 1)
        #expect(result?.title == "2025 콘서트")
        #expect(result?.artist == "아티스트")
        #expect(result?.status == .ongoing)
        #expect(result?.venue == "올림픽공원")
    }

    @Test("잘못된 상태값으로 콘서트 매핑 실패")
    func testFetchConcertInfoMappingWithInvalidStatus() {
        // Given
        let response = DTO.Response.FetchConcertInfo(
            id: 1,
            code: "CONCERT001",
            title: "2025 콘서트",
            startDate: "2025-01-01",
            endDate: "2025-01-02",
            status: "INVALID_STATUS",
            posterURL: "https://example.com/poster.jpg",
            artist: "아티스트",
            daysLeft: 10,
            ticketSite: nil,
            ticketURL: nil,
            venue: "올림픽공원",
            introduction: "콘서트 소개",
            label: nil
        )

        // When
        let result = mapper.toDomain(from: response)

        // Then
        #expect(result == nil)
    }

    // MARK: - Schedule Tests

    @Test("콘서트 일정 목록 매핑")
    func testFetchConcertScheduleMapping() {
        // Given
        let response: DTO.Response.FetchConcertSchedule = [
            DTO.Response.ConcertSchedule(id: 1, category: "공연", scheduledAt: "2025-01-01T18:00:00Z", type: "DAY1"),
            DTO.Response.ConcertSchedule(id: 2, category: "공연", scheduledAt: "2025-01-02T18:00:00Z", type: nil)
        ]

        // When
        let result = mapper.toDomain(from: response)

        // Then
        #expect(result.count == 2)
        #expect(result[0].id == 1)
        #expect(result[0].category == "공연")
        #expect(result[1].type == .none)
    }

    @Test("잘못된 날짜 형식으로 일정 매핑 실패")
    func testFetchConcertScheduleMappingWithInvalidDate() {
        // Given
        let response: DTO.Response.FetchConcertSchedule = [
            DTO.Response.ConcertSchedule(id: 1, category: "공연", scheduledAt: "invalid-date", type: "DAY1")
        ]

        // When
        let result = mapper.toDomain(from: response)

        // Then
        #expect(result.isEmpty)
    }

    // MARK: - Culture List Tests

    @Test("콘서트 문화 목록 매핑")
    func testFetchConcertCultureListMapping() {
        // Given
        let response: DTO.Response.FetchConcertCultureList = [
            DTO.Response.ConcertCulture(id: 1, concertID: 1, content: "응원봉 사용", title: "응원 문화"),
            DTO.Response.ConcertCulture(id: 2, concertID: 1, content: "떼창 금지", title: "주의사항")
        ]

        // When
        let result = mapper.toDomain(from: response)

        // Then
        #expect(result.count == 2)
        #expect(result[0].title == "응원 문화")
        #expect(result[1].content == "떼창 금지")
    }

    // MARK: - Merchandise List Tests

    @Test("MD 목록 매핑")
    func testFetchConcertMerchandiseListMapping() {
        // Given
        let response: DTO.Response.FetchConcertMerchandiseList = [
            DTO.Response.ConcertMerchandise(id: 1, name: "포토카드", price: "5000", imageURL: "https://example.com/md1.jpg"),
            DTO.Response.ConcertMerchandise(id: 2, name: "응원봉", price: "45000", imageURL: nil)
        ]

        // When
        let result = mapper.toDomain(from: response)

        // Then
        #expect(result.count == 2)
        #expect(result[0].name == "포토카드")
        #expect(result[0].price == "5000")
        #expect(result[1].imageURL == nil)
    }

    // MARK: - Artist Tests

    @Test("아티스트 정보 매핑")
    func testFetchConcertArtistInfoMapping() {
        // Given
        let response = DTO.Response.FetchConcertArtistInfo(
            id: 1,
            artist: "아티스트",
            debutYear: "2020",
            category: "아이돌",
            detail: "아티스트 소개",
            instagramURL: "https://instagram.com/artist",
            keywords: ["댄스", "보컬"],
            imageURL: "https://example.com/artist.jpg"
        )

        // When
        let result = mapper.toDomain(from: response)

        // Then
        #expect(result.id == 1)
        #expect(result.name == "아티스트")
        #expect(result.debutYear == "2020")
        #expect(result.keywords.count == 2)
    }
}
