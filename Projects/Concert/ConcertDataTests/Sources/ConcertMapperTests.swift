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

    // MARK: - Comment Tests

    @Test("댓글 목록 매핑")
    func testFetchConcertCommentListMapping() {
        // Given
        let response = DTO.Response.FetchConcertCommentList(
            data: [
                DTO.Response.FetchConcertCommentList.Comment(
                    id: 1,
                    userID: 100,
                    nickname: "유저1",
                    concertID: 1,
                    content: "기대돼요!",
                    createdAt: "2025-01-01T12:00:00Z"
                )
            ],
            cursor: DTO.Response.FetchConcertCommentList.Cursor(createdAt: "2025-01-01T12:00:00Z", id: 1),
            totalCount: 1
        )

        // When
        let result = mapper.toDomain(from: response)

        // Then
        #expect(result.comments.count == 1)
        #expect(result.comments[0].nickname == "유저1")
        #expect(result.totalCount == 1)
        #expect(result.cursor != nil)
    }

    @Test("댓글 생성 매핑")
    func testCreateConcertCommentMapping() {
        // Given
        let response = DTO.Response.CreateConcertComment(
            id: 1,
            userID: 100,
            nickname: "유저1",
            concertID: 1,
            content: "댓글 내용",
            createdAt: "2025-01-01T12:00:00Z"
        )

        // When
        let result = mapper.toDomain(from: response)

        // Then
        #expect(result.id == 1)
        #expect(result.userID == 100)
        #expect(result.nickname == "유저1")
        #expect(result.content == "댓글 내용")
    }

    // MARK: - Setlist Tests

    @Test("셋리스트 목록 매핑")
    func testFetchConcertSetlistListMapping() {
        // Given
        let response: DTO.Response.FetchConcertSetlistList = [
            DTO.Response.ConcertSetlist(
                id: 1,
                title: "2025 콘서트 Day1",
                imageURL: "https://example.com/setlist.jpg",
                type: "ONGOING",
                startDate: "2025-01-01T18:00:00Z",
                endDate: "2025-01-01T21:00:00Z",
                status: "expected",
                venue: "올림픽공원",
                artist: "아티스트"
            )
        ]

        // When
        let result = mapper.toDomain(from: response)

        // Then
        #expect(result.count == 1)
        #expect(result[0].id == 1)
        #expect(result[0].title == "2025 콘서트 Day1")
        #expect(result[0].type == .ongoing)
        #expect(result[0].status == .expected)
    }

    @Test("셋리스트 status가 nil일 때 none으로 매핑")
    func testFetchConcertSetlistListMappingWithNilStatus() {
        // Given
        let response: DTO.Response.FetchConcertSetlistList = [
            DTO.Response.ConcertSetlist(
                id: 1,
                title: "2025 콘서트",
                imageURL: nil,
                type: "ONGOING",
                startDate: "2025-01-01T18:00:00Z",
                endDate: "2025-01-01T21:00:00Z",
                status: nil,
                venue: "올림픽공원",
                artist: "아티스트"
            )
        ]

        // When
        let result = mapper.toDomain(from: response)

        // Then
        #expect(result.count == 1)
        #expect(result[0].status == .none)
    }

    @Test("잘못된 타입으로 셋리스트 매핑 실패")
    func testFetchConcertSetlistListMappingWithInvalidType() {
        // Given
        let response: DTO.Response.FetchConcertSetlistList = [
            DTO.Response.ConcertSetlist(
                id: 1,
                title: "2025 콘서트",
                imageURL: nil,
                type: "INVALID_TYPE",
                startDate: "2025-01-01T18:00:00Z",
                endDate: "2025-01-01T21:00:00Z",
                status: "expected",
                venue: "올림픽공원",
                artist: "아티스트"
            )
        ]

        // When
        let result = mapper.toDomain(from: response)

        // Then
        #expect(result.isEmpty)
    }

    // MARK: - Setlist Detail Tests

    @Test("셋리스트 상세 매핑")
    func testFetchConcertSetlistDetailMapping() {
        // Given
        let response = DTO.Response.FetchConcertSetlist(
            id: 1,
            title: "2025 콘서트 Day1",
            imageURL: "https://example.com/setlist.jpg",
            type: "ONGOING",
            startDate: "2025-01-01T18:00:00Z",
            endDate: "2025-01-01T21:00:00Z",
            status: "recent",
            venue: "올림픽공원",
            artist: "아티스트"
        )

        // When
        let result = mapper.toDomain(from: response)

        // Then
        #expect(result != nil)
        #expect(result?.id == 1)
        #expect(result?.type == .ongoing)
        #expect(result?.status == .recent)
    }

    @Test("잘못된 날짜로 셋리스트 상세 매핑 실패")
    func testFetchConcertSetlistDetailMappingWithInvalidDate() {
        // Given
        let response = DTO.Response.FetchConcertSetlist(
            id: 1,
            title: "2025 콘서트",
            imageURL: nil,
            type: "ONGOING",
            startDate: "invalid-date",
            endDate: "2025-01-01T21:00:00Z",
            status: "expected",
            venue: "올림픽공원",
            artist: "아티스트"
        )

        // When
        let result = mapper.toDomain(from: response)

        // Then
        #expect(result == nil)
    }

    // MARK: - Setlist Song Tests

    @Test("셋리스트 곡 목록 매핑")
    func testFetchSetlistSongListMapping() {
        // Given
        let response: DTO.Response.FetchSetlistSongList = [
            DTO.Response.SetlistSong(id: 1, title: "곡1", artist: "아티스트", orderIndex: 1),
            DTO.Response.SetlistSong(id: 2, title: "곡2", artist: "아티스트", orderIndex: 2)
        ]

        // When
        let result = mapper.toDomain(from: response)

        // Then
        #expect(result.count == 2)
        #expect(result[0].title == "곡1")
        #expect(result[0].orderIndex == 1)
        #expect(result[1].orderIndex == 2)
    }
}
