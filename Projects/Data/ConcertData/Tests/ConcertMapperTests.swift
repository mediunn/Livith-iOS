//
//  ConcertMapperTests.swift
//  DataTests
//
//  Created by 김진웅 on 1/22/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import XCTest

import LivithNetwork
import Domain
@testable import ConcertData

final class ConcertMapperTests: XCTestCase {
    private var sut: ConcertMapper!
    
    override func setUp() {
        super.setUp()
        sut = ConcertMapper()
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    func test_FetchConcertSetlist_EXPECTED_타입이_Setlist로_변환되어야_한다() throws {
        // Given
        let json = """
        {
            "id": 1,
            "title": "Eras Tour Expected",
            "imgUrl": "https://img.cjnews.cj.net/wp-content/uploads/2023/10/cgv_press_231025_01-692x1024.jpg",
            "type": "EXPECTED",
            "startDate": "2025.07.01",
            "endDate": "2025.07.05",
            "status": "대표",
            "venue": "고척스카이돔",
            "artist": "Taylor Swift"
        }
        """.data(using: .utf8)!
        
        let dto = try JSONDecoder().decode(DTO.Response.FetchConcertSetlist.self, from: json)
        
        // When
        let result = try XCTUnwrap(sut.toDomain(from: dto))
        
        // Then
        XCTAssertEqual(result.id, 1)
        XCTAssertEqual(result.title, "Eras Tour Expected")
        XCTAssertEqual(
            result.imageURL?.absoluteString,
            "https://img.cjnews.cj.net/wp-content/uploads/2023/10/cgv_press_231025_01-692x1024.jpg"
        )
        XCTAssertEqual(result.type, .expected)
        XCTAssertEqual(result.venue, "고척스카이돔")
        XCTAssertEqual(result.artist, "Taylor Swift")
        XCTAssertEqual(result.status, .represent)
        
        // Date verification
        let calendar = Calendar.current
        let startYear = calendar.component(.year, from: result.startDate)
        let startMonth = calendar.component(.month, from: result.startDate)
        let startDay = calendar.component(.day, from: result.startDate)
        XCTAssertEqual(startYear, 2025)
        XCTAssertEqual(startMonth, 7)
        XCTAssertEqual(startDay, 1)
    }
    
    func test_FetchConcertSetlist_ONGOING_타입이_Setlist로_변환되어야_한다() throws {
        // Given
        let json = """
        {
            "id": 27,
            "title": "Happier Than Ever Ongoing 2",
            "imgUrl": "https://img.cjnews.cj.net/wp-content/uploads/2023/01/cgv_press_20230118_01.jpg",
            "type": "ONGOING",
            "startDate": "2025.06.21",
            "endDate": "2025.06.25",
            "status": "대표",
            "venue": "잠실 올림픽 주경기장",
            "artist": "Billie Eilish"
        }
        """.data(using: .utf8)!
        
        let dto = try JSONDecoder().decode(DTO.Response.FetchConcertSetlist.self, from: json)
        
        // When
        let result = try XCTUnwrap(sut.toDomain(from: dto))
        
        // Then
        XCTAssertEqual(result.id, 27)
        XCTAssertEqual(result.title, "Happier Than Ever Ongoing 2")
        XCTAssertEqual(result.type, .ongoing)
        XCTAssertEqual(result.venue, "잠실 올림픽 주경기장")
        XCTAssertEqual(result.artist, "Billie Eilish")
        
        // Date verification
        let calendar = Calendar.current
        let startYear = calendar.component(.year, from: result.startDate)
        let startMonth = calendar.component(.month, from: result.startDate)
        let startDay = calendar.component(.day, from: result.startDate)
        XCTAssertEqual(startYear, 2025)
        XCTAssertEqual(startMonth, 6)
        XCTAssertEqual(startDay, 21)
    }
    
    func test_FetchConcertInfo_DTO가_Concert로_변환되어야_한다() throws {
        // Given
        let json = JSONLiterals.concertInfoJSON
        
        let dto = try JSONDecoder().decode(DTO.Response.FetchConcertInfo.self, from: json.data(using: .utf8)!)
        
        // When
        let result = try XCTUnwrap(sut.toDomain(from: dto))
        
        // Then
        XCTAssertEqual(result.id, 1)
        XCTAssertEqual(result.title, "Taylor Swift | The Eras Tour2")
        XCTAssertEqual(result.artist, "Taylor Swift")
        XCTAssertEqual(result.status, .upcoming)
        XCTAssertEqual(result.venue, "고척스카이돔")
        XCTAssertEqual(result.daysLeft, -6)
        XCTAssertEqual(result.introduction, "테일러 스위프트의 첫 내한! 한국에서도 인기 아티스트")
        XCTAssertEqual(result.label, "많이 찾는 콘서트 1위")
        
        let calendar = Calendar.current
        let startDate = try XCTUnwrap(result.startDate)
        let dateComponents = calendar.dateComponents([.year, .month, .day], from: startDate)
        XCTAssertEqual(dateComponents.year, 2025)
        XCTAssertEqual(dateComponents.month, 8)
        XCTAssertEqual(dateComponents.day, 10)
    }
    
    func test_FetchConcertInfo_잘못된_상태_형식인_경우_nil을_반환해야_한다() throws {
        // Given
        let json = JSONLiterals.concertInfoWithInvalidStatus
        
        let dto = try JSONDecoder().decode(DTO.Response.FetchConcertInfo.self, from: json.data(using: .utf8)!)
        
        // When
        let result = sut.toDomain(from: dto)
        
        // Then
        XCTAssertNil(result)
    }
    
    func test_FetchConcertInfo_잘못된_날짜_형식인_경우_nil을_반환해야_한다() throws {
        // Given
        let json = JSONLiterals.concertInfoWithInvalidDate
        
        let dto = try JSONDecoder().decode(DTO.Response.FetchConcertInfo.self, from: json.data(using: .utf8)!)
        
        // When
        let result = sut.toDomain(from: dto)
        
        // Then
        XCTAssertNil(result)
    }
    
    func test_FetchHomeSectionList가_ConcertSection_List로_변환되어야_한다() throws {
        // Given
        let json = """
        [
            {
                "id": 1,
                "sectionTitle": "이 달의 인기 콘서트",
                "concerts": [
                    {
                        "id": 1,
                        "code": "TS2025US02",
                        "title": "Taylor Swift | The Eras Tour2",
                        "startDate": "2025.08.10",
                        "endDate": "2025.08.10",
                        "status": "UPCOMING",
                        "poster": "https://upload.wikimedia.org/wikipedia/en/d/d6/Taylor_Swift_The_Eras_Tour_film_promotional_poster.png",
                        "artist": "Taylor Swift",
                        "createdAt": "2025-08-24T06:27:05.000Z",
                        "updatedAt": "2025-08-24T06:27:05.000Z",
                        "artistId": 1,
                        "ticketSite": "Ticketmaster",
                        "ticketUrl": "https://www.ticketmaster.com/taylor-swift-tickets/artist/1094215",
                        "venue": "고척스카이돔",
                        "introduction": "테일러 스위프트의 첫 내한! 한국에서도 인기 아티스트",
                        "label": "많이 찾는 콘서트 1위",
                        "sortedIndex": 1,
                        "daysLeft": -20
                    },
                    {
                        "id": 2,
                        "code": "HS2025UK02",
                        "title": "Harry Styles | Love On Tour2",
                        "startDate": "2025.09.15",
                        "endDate": "2025.09.15",
                        "status": "UPCOMING",
                        "poster": "https://upload.wikimedia.org/wikipedia/en/d/d5/Harry_Styles_-_Love_on_Tour.png",
                        "artist": "Harry Styles",
                        "createdAt": "2025-08-24T06:27:05.000Z",
                        "updatedAt": "2025-08-24T06:27:05.000Z",
                        "artistId": 2,
                        "ticketSite": "Ticketmaster UK",
                        "ticketUrl": "https://www.ticketmaster.co.uk/harry-styles-tickets/artist/5209323",
                        "venue": "KSPO DOME",
                        "introduction": "원디렉션 출신 해리 스타일스, 두 번째 내한 공연!",
                        "label": "많이 찾는 콘서트 2위",
                        "sortedIndex": 2,
                        "daysLeft": 16
                    }
                ]
            },
            {
                "id": 2,
                "sectionTitle": "이 달의 최신 콘서트",
                "concerts": [
                    {
                        "id": 4,
                        "code": "ES2025DE02",
                        "title": "Ed Sheeran | Mathematics Tour2",
                        "startDate": "2025.07.30",
                        "endDate": "2025.07.30",
                        "status": "ONGOING",
                        "poster": "https://www.warnermusic.co.kr/wp-content/uploads/2019/01/edsheeran_liveinseoul_poster-724x1024.jpg",
                        "artist": "Ed Sheeran",
                        "createdAt": "2025-08-24T06:27:05.000Z",
                        "updatedAt": "2025-08-24T06:27:05.000Z",
                        "artistId": 4,
                        "ticketSite": "Eventim",
                        "ticketUrl": "https://www.eventim.de/artist/ed-sheeran/",
                        "venue": "올림픽공원 체조경기장",
                        "introduction": "어쿠스틱 감성의 끝판왕, 에드 시런의 라이브 무대!",
                        "label": null,
                        "sortedIndex": 1,
                        "daysLeft": -31
                    }
                ]
            }
        ]
        """.data(using: .utf8)!
        
        let dto = try JSONDecoder().decode(DTO.Response.FetchHomeSectionList.self, from: json)
        
        // When
        let result = sut.toDomain(from: dto)
        
        // Then
        XCTAssertEqual(result.count, 2)
        
        // 첫 번째 섹션 검증
        XCTAssertEqual(result[0].id, 1)
        XCTAssertEqual(result[0].title, "이 달의 인기 콘서트")
        XCTAssertEqual(result[0].concertList.count, 2)
        XCTAssertEqual(result[0].concertList[0].title, "Taylor Swift | The Eras Tour2")
        XCTAssertEqual(result[0].concertList[0].status, .upcoming)
        XCTAssertEqual(result[0].concertList[0].venue, "고척스카이돔")
        XCTAssertEqual(result[0].concertList[0].label, "많이 찾는 콘서트 1위")
        XCTAssertEqual(result[0].concertList[1].title, "Harry Styles | Love On Tour2")
        
        // 두 번째 섹션 검증
        XCTAssertEqual(result[1].id, 2)
        XCTAssertEqual(result[1].title, "이 달의 최신 콘서트")
        XCTAssertEqual(result[1].concertList.count, 1)
        XCTAssertEqual(result[1].concertList[0].title, "Ed Sheeran | Mathematics Tour2")
        XCTAssertEqual(result[1].concertList[0].status, .ongoing)
        XCTAssertNil(result[1].concertList[0].label)
    }
    
    func test_FetchSectionList_DTO가_ConcertSection_List로_변환되어야_한다() throws {
        // Given
        let json = """
        [{
            "id": 1,
            "sectionTitle": "인기 콘서트",
            "concerts": [{
                "id": 1,
                "code": "C1",
                "title": "Taylor Swift",
                "startDate": "2025.08.10",
                "endDate": "2025.08.10",
                "status": "UPCOMING",
                "poster": "https://example.com/poster.jpg",
                "artist": "Taylor Swift",
                "ticketSite": "Ticketmaster",
                "ticketUrl": "https://example.com/ticket",
                "venue": "고척스카이돔",
                "introduction": "Test",
                "daysLeft": -20
            }]
        }]
        """.data(using: .utf8)!
        
        let dto = try JSONDecoder().decode(DTO.Response.FetchSectionList.self, from: json)
        
        // When
        let result = sut.toDomain(from: dto)
        
        // Then
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result[0].title, "인기 콘서트")
        XCTAssertEqual(result[0].concertList.count, 1)
        XCTAssertEqual(result[0].concertList[0].id, 1)
        XCTAssertEqual(result[0].concertList[0].status, .upcoming)
    }
    
    func test_FetchSectionList_잘못된_날짜_형식인_경우_해당_콘서트는_제외되어야_한다() throws {
        // Given
        let json = JSONLiterals.sectionWithConcerts([
            JSONLiterals.validConcert,
            JSONLiterals.invalidDateConcert
        ])
        
        let dto = try JSONDecoder().decode(DTO.Response.FetchSectionList.self, from: json.data(using: .utf8)!)
        
        // When
        let result = sut.toDomain(from: dto)
        
        // Then
        XCTAssertEqual(result[0].concertList.count, 1)
        XCTAssertEqual(result[0].concertList[0].id, 1)
    }
    
    func test_FetchSectionList_잘못된_상태_형식인_경우_해당_콘서트는_제외되어야_한다() throws {
        // Given
        let json = JSONLiterals.sectionWithConcerts([
            JSONLiterals.validConcert,
            JSONLiterals.invalidStatusConcert
        ])
        
        let dto = try JSONDecoder().decode(DTO.Response.FetchSectionList.self, from: json.data(using: .utf8)!)
        
        // When
        let result = sut.toDomain(from: dto)
        
        // Then
        XCTAssertEqual(result[0].concertList.count, 1)
        XCTAssertEqual(result[0].concertList[0].id, 1)
    }

    func test_FetchRecommendedConcertList_DTO가_Concert_List로_변환되어야_한다() throws {
        // Given
        let json = """
        [
            {
                "id": 1,
                "code": "TS2025US02",
                "title": "Taylor Swift | The Eras Tour2",
                "startDate": "2025.08.10",
                "endDate": "2025.08.10",
                "status": "UPCOMING",
                "poster": "https://upload.wikimedia.org/wikipedia/en/d/d6/Taylor_Swift_The_Eras_Tour_film_promotional_poster.png",
                "artist": "Taylor Swift",
                "createdAt": "2025-08-24T06:27:05.000Z",
                "updatedAt": "2025-08-24T06:27:05.000Z",
                "artistId": 1,
                "ticketSite": "Ticketmaster",
                "ticketUrl": "https://www.ticketmaster.com/taylor-swift-tickets/artist/1094215",
                "venue": "고척스카이돔",
                "introduction": "테일러 스위프트의 첫 내한! 한국에서도 인기 아티스트",
                "label": "많이 찾는 콘서트 1위",
                "sortedIndex": 1,
                "daysLeft": -20
            },
            {
                "id": 2,
                "code": "HS2025UK02",
                "title": "Harry Styles | Love On Tour2",
                "startDate": "2025.09.15",
                "endDate": "2025.09.15",
                "status": "UPCOMING",
                "poster": "https://upload.wikimedia.org/wikipedia/en/d/d5/Harry_Styles_-_Love_on_Tour.png",
                "artist": "Harry Styles",
                "createdAt": "2025-08-24T06:27:05.000Z",
                "updatedAt": "2025-08-24T06:27:05.000Z",
                "artistId": 2,
                "ticketSite": "Ticketmaster UK",
                "ticketUrl": "https://www.ticketmaster.co.uk/harry-styles-tickets/artist/5209323",
                "venue": "KSPO DOME",
                "introduction": "원디렉션 출신 해리 스타일스, 두 번째 내한 공연!",
                "label": "많이 찾는 콘서트 2위",
                "sortedIndex": 2,
                "daysLeft": 16
            }
        ]
        """.data(using: .utf8)!
        
        let dto = try JSONDecoder().decode(DTO.Response.FetchRecommendedConcertList.self, from: json)
        
        // When
        let result = sut.toDomain(from: dto)
        
        // Then
        XCTAssertEqual(result.count, 2)
        XCTAssertEqual(result[0].id, 1)
        XCTAssertEqual(result[0].title, "Taylor Swift | The Eras Tour2")
        XCTAssertEqual(result[0].artist, "Taylor Swift")
        XCTAssertEqual(result[1].id, 2)
        XCTAssertEqual(result[1].title, "Harry Styles | Love On Tour2")
    }

    // MARK: - FetchConcertSchedule Tests
    func test_FetchConcertSchedule_DTO가_ConcertSchedule_List로_변환되어야_한다() throws {
        // Given
        let json = JSONLiterals.validConcertScheduleList
        let dto = try JSONDecoder().decode(DTO.Response.FetchConcertSchedule.self, from: json.data(using: .utf8)!)
        
        // When
        let result = sut.toDomain(from: dto)
        
        // Then
        XCTAssertEqual(result.count, 3)
        
        // 첫 번째 스케줄 검증
        let firstSchedule = result[0]
        XCTAssertEqual(firstSchedule.id, 2)
        XCTAssertEqual(firstSchedule.category, "티켓팅 오픈")
        XCTAssertEqual(firstSchedule.type, .ticketing)
        
        let calendar = Calendar.current
        let firstYear = calendar.component(.year, from: firstSchedule.scheduledAt)
        let firstMonth = calendar.component(.month, from: firstSchedule.scheduledAt)
        let firstDay = calendar.component(.day, from: firstSchedule.scheduledAt)
        XCTAssertEqual(firstYear, 2025)
        XCTAssertEqual(firstMonth, 6)
        XCTAssertEqual(firstDay, 15)
        
        // 마지막 스케줄 검증
        let lastSchedule = result[2]
        XCTAssertEqual(lastSchedule.id, 1)
        XCTAssertEqual(lastSchedule.category, "공연")
        XCTAssertEqual(lastSchedule.type, .none)
        
        let lastYear = calendar.component(.year, from: lastSchedule.scheduledAt)
        let lastMonth = calendar.component(.month, from: lastSchedule.scheduledAt)
        let lastDay = calendar.component(.day, from: lastSchedule.scheduledAt)
        XCTAssertEqual(lastYear, 2025)
        XCTAssertEqual(lastMonth, 8)
        XCTAssertEqual(lastDay, 10)
    }
    
    func test_FetchConcertSchedule_잘못된_날짜_형식인_경우_해당_스케줄은_제외되어야_한다() throws {
        // Given
        let json = JSONLiterals.concertScheduleWithInvalidDate
        let dto = try JSONDecoder().decode(DTO.Response.FetchConcertSchedule.self, from: json.data(using: .utf8)!)
        
        // When
        let result = sut.toDomain(from: dto)
        
        // Then
        // 잘못된 날짜는 compactMap에서 제외되므로 유효한 스케줄만 반환
        XCTAssertEqual(result.count, 2)
        
        // 첫 번째 항목이 유효한 스케줄임을 확인
        let calendar = Calendar.current
        let firstYear = calendar.component(.year, from: result[0].scheduledAt)
        let firstMonth = calendar.component(.month, from: result[0].scheduledAt)
        XCTAssertEqual(firstYear, 2025)
        XCTAssertEqual(firstMonth, 6)
    }
    
    func test_FetchConcertSchedule_모든_필드가_nil인_경우_공백_배열을_반환해야_한다() throws {
        // Given
        let json = "[]"
        let dto = try JSONDecoder().decode(DTO.Response.FetchConcertSchedule.self, from: json.data(using: .utf8)!)
        
        // When
        let result = sut.toDomain(from: dto)
        
        // Then
        XCTAssertTrue(result.isEmpty)
    }
    
    // MARK: - FetchConcertCultureList Tests
    
    func test_FetchConcertCultureList_DTO가_ConcertCulture_List로_변환되어야_한다() throws {
        // Given
        let json = JSONLiterals.validConcertCultureList
        let dto = try JSONDecoder().decode(DTO.Response.FetchConcertCultureList.self, from: json.data(using: .utf8)!)
        
        // When
        let result = sut.toDomain(from: dto)
        
        // Then
        XCTAssertEqual(result.count, 2)
        
        // 첫 번째 문화 항목 검증
        let firstCulture = result[0]
        XCTAssertEqual(firstCulture.id, 1)
        XCTAssertEqual(firstCulture.concertID, 1)
        XCTAssertEqual(firstCulture.title, "플래시 금지")
        XCTAssertEqual(firstCulture.content, "테일러 스위프트 공연 중 플래시 사용은 금지되어 있어요 ✨")
        
        // 두 번째 문화 항목 검증
        let secondCulture = result[1]
        XCTAssertEqual(secondCulture.id, 2)
        XCTAssertEqual(secondCulture.concertID, 1)
        XCTAssertEqual(secondCulture.title, "정숙한 관람")
        XCTAssertEqual(secondCulture.content, "감동적인 순간을 방해하지 않도록 큰 소리 대화는 자제해주세요 🫶")
    }
    
    func test_FetchConcertCultureList_공백_배열을_반환해야_한다() throws {
        // Given
        let json = "[]"
        let dto = try JSONDecoder().decode(DTO.Response.FetchConcertCultureList.self, from: json.data(using: .utf8)!)
        
        // When
        let result = sut.toDomain(from: dto)
        
        // Then
        XCTAssertTrue(result.isEmpty)
    }
    
    func test_FetchConcertCultureList_단일_항목으로_변환되어야_한다() throws {
        // Given
        let json = JSONLiterals.singleConcertCulture
        let dto = try JSONDecoder().decode(DTO.Response.FetchConcertCultureList.self, from: json.data(using: .utf8)!)
        
        // When
        let result = sut.toDomain(from: dto)
        
        // Then
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result[0].id, 1)
        XCTAssertEqual(result[0].concertID, 1)
        XCTAssertEqual(result[0].title, "플래시 금지")
    }
}


// MARK: - JSON Literals
private enum JSONLiterals {
    // Base valid concert data
    static let baseValidConcert = """
    {"id": 1, "code": "C1", "title": "Valid", "startDate": "2025.08.10", "endDate": "2025.08.10", "status": "UPCOMING", "poster": "https://example.com/1.jpg", "artist": "A1", "ticketSite": "T1", "ticketUrl": "https://t.com", "venue": "V1", "introduction": "I1", "daysLeft": 10}
    """
    
    static let validConcert = baseValidConcert
    
    static let invalidDateConcert = """
    {"id": 2, "code": "C2", "title": "Invalid", "startDate": "invalid", "endDate": "2025.08.10", "status": "UPCOMING", "poster": "https://example.com/2.jpg", "artist": "A2", "ticketSite": "T2", "ticketUrl": "https://t.com", "venue": "V2", "introduction": "I2", "daysLeft": 10}
    """
    
    static let invalidStatusConcert = """
    {"id": 2, "code": "C2", "title": "Invalid", "startDate": "2025.08.10", "endDate": "2025.08.10", "status": "INVALID", "poster": "https://example.com/2.jpg", "artist": "A2", "ticketSite": "T2", "ticketUrl": "https://t.com", "venue": "V2", "introduction": "I2", "daysLeft": 10}
    """
    
    static let invalidPosterConcert = """
    {"id": 2, "code": "C2", "title": "Invalid", "startDate": "2025.08.10", "endDate": "2025.08.10", "status": "UPCOMING", "poster": "invalid-url", "artist": "A2", "ticketSite": "T2", "ticketUrl": "https://t.com", "venue": "V2", "introduction": "I2", "daysLeft": 10}
    """
    
    // Base valid concert info (matches baseValidConcert fields)
    static let baseValidConcertInfo = """
    {"id": 1, "startDate": "2025.08.10", "endDate": "2025.08.10", "status": "UPCOMING", "poster": "https://example.com/poster.jpg", "daysLeft": 10, "venue": "Venue", "introduction": "Intro"}
    """
    
    static let concertInfoJSON = """
    {"id": 1, "code": "TS2025US02", "title": "Taylor Swift | The Eras Tour2", "startDate": "2025.08.10", "endDate": "2025.08.10", "status": "UPCOMING", "poster": "https://upload.wikimedia.org/wikipedia/en/d/d6/Taylor_Swift_The_Eras_Tour_film_promotional_poster.png", "artist": "Taylor Swift", "daysLeft": -6, "ticketSite": "Ticketmaster", "ticketUrl": "https://www.ticketmaster.com/taylor-swift-tickets/artist/1094215", "venue": "고척스카이돔", "introduction": "테일러 스위프트의 첫 내한! 한국에서도 인기 아티스트", "label": "많이 찾는 콘서트 1위"}
    """
    
    static let concertInfoWithInvalidStatus = """
    {"id": 1, "code": "C1", "title": "Concert", "startDate": "2025.08.10", "endDate": "2025.08.10", "status": "INVALID", "poster": "https://example.com/poster.jpg", "artist": "Artist", "daysLeft": 10, "venue": "Venue", "introduction": "Intro"}
    """
    
    static let concertInfoWithInvalidDate = """
    {"id": 1, "code": "C1", "title": "Concert", "startDate": "invalid", "endDate": "2025.08.10", "status": "UPCOMING", "poster": "https://example.com/poster.jpg", "artist": "Artist", "daysLeft": 10, "venue": "Venue", "introduction": "Intro"}
    """
    
    static let concertInfoWithInvalidPoster = """
    {"id": 1, "code": "C1", "title": "Concert", "startDate": "2025.08.10", "endDate": "2025.08.10", "status": "UPCOMING", "poster": "invalid-url", "artist": "Artist", "daysLeft": 10, "venue": "Venue", "introduction": "Intro"}
    """
    
    // Concert Schedule literals
    static let validConcertScheduleList = """
    [
        {"id": 2, "category": "티켓팅 오픈", "scheduledAt": "2025-06-15T12:00:00.000Z", "type": "TICKETING"},
        {"id": 3, "category": "공식 굿즈 사전 판매", "scheduledAt": "2025-08-01T10:00:00.000Z", "type": null},
        {"id": 1, "category": "공연", "scheduledAt": "2025-08-10T19:00:00.000Z", "type": null}
    ]
    """
    
    static let concertScheduleWithInvalidDate = """
    [
        {"id": 2, "category": "티켓팅 오픈", "scheduledAt": "2025-06-15T12:00:00.000Z", "type": "TICKETING"},
        {"id": 3, "category": "공식 굿즈 사전 판매", "scheduledAt": "invalid-date", "type": null},
        {"id": 1, "category": "공연", "scheduledAt": "2025-08-10T19:00:00.000Z", "type": null}
    ]
    """
    
    // Concert Culture literals
    static let validConcertCultureList = """
    [
        {"id": 1, "concertId": 1, "content": "테일러 스위프트 공연 중 플래시 사용은 금지되어 있어요 ✨", "title": "플래시 금지"},
        {"id": 2, "concertId": 1, "content": "감동적인 순간을 방해하지 않도록 큰 소리 대화는 자제해주세요 🫶", "title": "정숙한 관람"}
    ]
    """
    
    static let singleConcertCulture = """
    [
        {"id": 1, "concertId": 1, "content": "테일러 스위프트 공연 중 플래시 사용은 금지되어 있어요 ✨", "title": "플래시 금지"}
    ]
    """
    
    static func sectionWithConcerts(_ concerts: [String]) -> String {
        let concertArray = concerts.joined(separator: ",")
        return """
        [{
            "id": 1,
            "sectionTitle": "테스트",
            "concerts": [\(concertArray)]
        }]
        """
    }
}
