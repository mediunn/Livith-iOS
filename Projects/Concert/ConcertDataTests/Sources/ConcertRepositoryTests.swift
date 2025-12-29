//
//  ConcertRepositoryTests.swift
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

@Suite("ConcertRepository Tests")
struct ConcertRepositoryTests {

    // MARK: - FetchConcertInfo Tests

    @Test("콘서트 정보 조회 성공")
    func test_콘서트정보조회_유효한응답_콘서트반환() async throws {
        // Given
        let mockService = MockConcertService()
        mockService.mockResponse = DTO.Response.FetchConcertInfo(
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
        let repository = ConcertRepositoryImpl(service: mockService)

        // When
        let result = try await repository.fetchConcertInfo(concertID: 1)

        // Then
        #expect(result.id == 1)
        #expect(result.title == "2025 콘서트")
        #expect(result.status == .ongoing)
    }

    @Test("콘서트 정보 조회 실패 - 네트워크 에러")
    func test_콘서트정보조회_네트워크에러_에러반환() async {
        // Given
        let mockService = MockConcertService()
        mockService.mockError = NetworkError.serverError(message: "서버 에러")
        let repository = ConcertRepositoryImpl(service: mockService)

        // When & Then
        do {
            _ = try await repository.fetchConcertInfo(concertID: 1)
            Issue.record("에러가 발생해야 합니다")
        } catch {
            #expect(error == .serverError)
        }
    }

    @Test("콘서트 정보 조회 실패 - 잘못된 응답")
    func test_콘서트정보조회_잘못된응답_에러반환() async {
        // Given
        let mockService = MockConcertService()
        mockService.mockResponse = DTO.Response.FetchConcertInfo(
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
        let repository = ConcertRepositoryImpl(service: mockService)

        // When & Then
        do {
            _ = try await repository.fetchConcertInfo(concertID: 1)
            Issue.record("에러가 발생해야 합니다")
        } catch {
            #expect(error == .invalidResponse)
        }
    }

    // MARK: - FetchConcertSchedule Tests

    @Test("콘서트 일정 조회 성공")
    func test_콘서트일정조회_유효한응답_일정목록반환() async throws {
        // Given
        let mockService = MockConcertService()
        mockService.mockResponse = [
            DTO.Response.ConcertSchedule(id: 1, category: "공연", scheduledAt: "2025-01-01T18:00:00Z", type: "DAY1"),
            DTO.Response.ConcertSchedule(id: 2, category: "공연", scheduledAt: "2025-01-02T18:00:00Z", type: "DAY2")
        ] as DTO.Response.FetchConcertSchedule
        let repository = ConcertRepositoryImpl(service: mockService)

        // When
        let result = try await repository.fetchConcertSchedule(concertID: 1)

        // Then
        #expect(result.count == 2)
        #expect(result[0].category == "공연")
    }

    @Test("콘서트 일정 조회 실패 - 네트워크 에러")
    func test_콘서트일정조회_네트워크에러_에러반환() async {
        // Given
        let mockService = MockConcertService()
        mockService.mockError = NetworkError.notFound(message: nil)
        let repository = ConcertRepositoryImpl(service: mockService)

        // When & Then
        do {
            _ = try await repository.fetchConcertSchedule(concertID: 1)
            Issue.record("에러가 발생해야 합니다")
        } catch {
            #expect(error == .notFound)
        }
    }

    // MARK: - FetchConcertCultureList Tests

    @Test("콘서트 문화 목록 조회 성공")
    func test_콘서트문화조회_유효한응답_문화목록반환() async throws {
        // Given
        let mockService = MockConcertService()
        mockService.mockResponse = [
            DTO.Response.ConcertCulture(id: 1, concertID: 1, content: "응원봉 사용", title: "응원 문화")
        ] as DTO.Response.FetchConcertCultureList
        let repository = ConcertRepositoryImpl(service: mockService)

        // When
        let result = try await repository.fetchConcertCultureList(concertID: 1)

        // Then
        #expect(result.count == 1)
        #expect(result[0].title == "응원 문화")
    }

    // MARK: - FetchConcertMerchandiseList Tests

    @Test("MD 목록 조회 성공")
    func test_MD목록조회_유효한응답_MD목록반환() async throws {
        // Given
        let mockService = MockConcertService()
        mockService.mockResponse = [
            DTO.Response.ConcertMerchandise(id: 1, name: "포토카드", price: "5000", imageURL: nil)
        ] as DTO.Response.FetchConcertMerchandiseList
        let repository = ConcertRepositoryImpl(service: mockService)

        // When
        let result = try await repository.fetchConcertMerchandiseList(concertID: 1)

        // Then
        #expect(result.count == 1)
        #expect(result[0].name == "포토카드")
    }

    // MARK: - FetchConcertArtistInfo Tests

    @Test("아티스트 정보 조회 성공")
    func test_아티스트정보조회_유효한응답_아티스트반환() async throws {
        // Given
        let mockService = MockConcertService()
        mockService.mockResponse = DTO.Response.FetchConcertArtistInfo(
            id: 1,
            artist: "아티스트",
            debutYear: "2020",
            category: "아이돌",
            detail: "소개",
            instagramURL: nil,
            keywords: ["댄스"],
            imageURL: nil
        )
        let repository = ConcertRepositoryImpl(service: mockService)

        // When
        let result = try await repository.fetchConcertArtistInfo(concertID: 1)

        // Then
        #expect(result.name == "아티스트")
        #expect(result.debutYear == "2020")
    }
}
