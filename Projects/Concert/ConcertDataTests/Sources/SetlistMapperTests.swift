//
//  SetlistMapperTests.swift
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

@Suite("SetlistMapper Tests")
struct SetlistMapperTests {
    let mapper = ConcertMapper()

    // MARK: - Setlist List Tests

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
