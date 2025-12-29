//
//  SetlistRepositoryTests.swift
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

@Suite("SetlistRepository Tests")
struct SetlistRepositoryTests {

    // MARK: - FetchConcertSetlist Tests

    @Test("셋리스트 상세 조회 성공")
    func test_셋리스트상세조회_유효한응답_셋리스트반환() async throws {
        // Given
        let mockService = MockSetlistService()
        mockService.mockResponse = DTO.Response.FetchConcertSetlist(
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
        let repository = SetlistRepositoryImpl(service: mockService)

        // When
        let result = try await repository.fetchConcertSetlist(setlistID: 1)

        // Then
        #expect(result.id == 1)
        #expect(result.title == "2025 콘서트 Day1")
        #expect(result.status == .expected)
    }

    @Test("셋리스트 상세 조회 실패 - 네트워크 에러")
    func test_셋리스트상세조회_네트워크에러_에러반환() async {
        // Given
        let mockService = MockSetlistService()
        mockService.mockError = NetworkError.serverError(message: nil)
        let repository = SetlistRepositoryImpl(service: mockService)

        // When & Then
        do {
            _ = try await repository.fetchConcertSetlist(setlistID: 1)
            Issue.record("에러가 발생해야 합니다")
        } catch {
            #expect(error == .serverError)
        }
    }

    @Test("셋리스트 상세 조회 실패 - 잘못된 응답")
    func test_셋리스트상세조회_잘못된응답_에러반환() async {
        // Given
        let mockService = MockSetlistService()
        mockService.mockResponse = DTO.Response.FetchConcertSetlist(
            id: 1,
            title: "2025 콘서트",
            imageURL: nil,
            type: "INVALID_TYPE",
            startDate: "2025-01-01T18:00:00Z",
            endDate: "2025-01-01T21:00:00Z",
            status: nil,
            venue: "올림픽공원",
            artist: "아티스트"
        )
        let repository = SetlistRepositoryImpl(service: mockService)

        // When & Then
        do {
            _ = try await repository.fetchConcertSetlist(setlistID: 1)
            Issue.record("에러가 발생해야 합니다")
        } catch {
            #expect(error == .invalidResponse)
        }
    }

    // MARK: - FetchSetlistSongList Tests

    @Test("셋리스트 곡 목록 조회 성공")
    func test_셋리스트곡목록조회_유효한응답_곡목록반환() async throws {
        // Given
        let mockService = MockSetlistService()
        mockService.mockResponse = [
            DTO.Response.SetlistSong(id: 1, title: "곡1", artist: "아티스트", orderIndex: 1),
            DTO.Response.SetlistSong(id: 2, title: "곡2", artist: "아티스트", orderIndex: 2)
        ] as DTO.Response.FetchSetlistSongList
        let repository = SetlistRepositoryImpl(service: mockService)

        // When
        let result = try await repository.fetchSetlistSongList(setlistID: 1)

        // Then
        #expect(result.count == 2)
        #expect(result[0].title == "곡1")
        #expect(result[1].orderIndex == 2)
    }

    @Test("셋리스트 곡 목록 조회 실패 - 네트워크 에러")
    func test_셋리스트곡목록조회_네트워크에러_에러반환() async {
        // Given
        let mockService = MockSetlistService()
        mockService.mockError = NetworkError.notFound(message: nil)
        let repository = SetlistRepositoryImpl(service: mockService)

        // When & Then
        do {
            _ = try await repository.fetchSetlistSongList(setlistID: 1)
            Issue.record("에러가 발생해야 합니다")
        } catch {
            #expect(error == .notFound)
        }
    }
}
