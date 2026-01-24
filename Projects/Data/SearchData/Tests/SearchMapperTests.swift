//
//  SearchMapperTests.swift
//  DataTests
//
//  Created by 김진웅 on 1/21/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import XCTest

import LivithNetwork
import Domain
@testable import SearchData

final class SearchMapperTests: XCTestCase {
    private var sut: SearchMapper!
    
    override func setUp() {
        super.setUp()
        sut = SearchMapper()
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    func test_FetchBannerList_DTO가_Banner_Entity_List로_변환되어야_한다() throws {
        // Given
        let json = """
        [
            {
              "id": 1,
              "title": "라이빗 인스타그램 운영 중!",
              "category": "@livith_concert",
              "imgUrl": "https://github.com/mediunn/Livith-Assets/blob/main/banner/instagram.png?raw=true",
              "content": "인스타에서 아티스트 릴스, 숨겨진 비하인드 이야기, \\n떼창 가이드 등 다양한 컨텐츠를 확인해 보세요!"
            },
            {
              "id": 2,
              "title": "팀 라이빗의 이야기가 궁금하다면?",
              "category": "라이빗 팀블로그",
              "imgUrl": "https://github.com/mediunn/Livith-Assets/blob/main/banner/tistory.png?raw=true",
              "content": "라이빗 서비스를 만들어가는 팀 라이빗의 이야기가 궁금하다면? \\n티스토리에서 라이빗을 검색해보세요!"
            }
        ]
        """.data(using: .utf8)!
        
        let dto = try JSONDecoder().decode(DTO.Response.FetchBannerList.self, from: json)
        
        // When
        let result = sut.toDomain(from: dto)
        
        // Then
        XCTAssertEqual(result.count, 2)
        
        XCTAssertEqual(result[0].id, 1)
        XCTAssertEqual(result[0].title, "라이빗 인스타그램 운영 중!")
        XCTAssertEqual(result[0].category, "@livith_concert")
        XCTAssertEqual(result[0].imageURL?.absoluteString, "https://github.com/mediunn/Livith-Assets/blob/main/banner/instagram.png?raw=true")
        XCTAssertTrue(result[0].description.contains("인스타에서 아티스트 릴스"))
        
        XCTAssertEqual(result[1].id, 2)
        XCTAssertEqual(result[1].title, "팀 라이빗의 이야기가 궁금하다면?")
        XCTAssertEqual(result[1].category, "라이빗 팀블로그")
        XCTAssertEqual(result[1].imageURL?.absoluteString, "https://github.com/mediunn/Livith-Assets/blob/main/banner/tistory.png?raw=true")
        XCTAssertTrue(result[1].description.contains("티스토리에서 라이빗을 검색해보세요!"))
    }
    
    func test_FetchFilterSearchResult_DTO가_SearchResultEntity로_변환되어야_한다() throws {
        // Given
        let json = """
        {
          "data": [
            {
              "id": 3,
              "code": "AG2025JP02",
              "title": "Ariana Grande Live in Tokyo2",
              "startDate": "2025.10.05",
              "endDate": "2025.10.06",
              "status": "UPCOMING",
              "poster": "https://ticketimage.interpark.com/playdb/extern/EdailyNews/S_PS17062600241.jpg",
              "artist": "Ariana Grande",
              "daysLeft": 38,
              "ticketSite": "eplus",
              "ticketUrl": "https://eplus.jp/ariana-grande/",
              "venue": "인천 아시아드 주경기장",
              "introduction": "아리아나 그란데의 폭발적인 가창력과 퍼포먼스를 한국에서!",
              "label": "많이 찾는 콘서트 3위"
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
              "daysLeft": 18,
              "ticketSite": "Ticketmaster UK",
              "ticketUrl": "https://www.ticketmaster.co.uk/harry-styles-tickets/artist/5209323",
              "venue": "KSPO DOME",
              "introduction": "원디렉션 출신 해리 스타일스, 두 번째 내한 공연!",
              "label": "많이 찾는 콘서트 2위"
            },
            {
              "id": 1,
              "code": "TS2025US02",
              "title": "Taylor Swift | The Eras Tour2",
              "startDate": "2025.08.10",
              "endDate": "2025.08.10",
              "status": "UPCOMING",
              "poster": "https://upload.wikimedia.org/wikipedia/en/d/d6/Taylor_Swift_The_Eras_Tour_film_promotional_poster.png",
              "artist": "Taylor Swift",
              "daysLeft": -18,
              "ticketSite": "Ticketmaster",
              "ticketUrl": "https://www.ticketmaster.com/taylor-swift-tickets/artist/1094215",
              "venue": "고척스카이돔",
              "introduction": "테일러 스위프트의 첫 내한! 한국에서도 인기 아티스트",
              "label": "많이 찾는 콘서트 1위"
            }
          ],
          "cursor": {
            "value": "Taylor Swift | The Eras Tour2",
            "id": 1
          },
          "totalCount": 5
        }
        """.data(using: .utf8)!
        
        let dto = try JSONDecoder().decode(DTO.Response.FetchFilterSearchResult.self, from: json)
        
        // When
        let result = sut.toDomain(from: dto)
        
        // Then
        XCTAssertEqual(result.concerts.count, 3)
        XCTAssertEqual(result.concerts[0].title, "Ariana Grande Live in Tokyo2")
        XCTAssertEqual(result.concerts[0].status, .upcoming)
        XCTAssertEqual(result.cursor?.value, "Taylor Swift | The Eras Tour2")
        XCTAssertEqual(result.totalCount, 5)
        
        // Date check
        let calendar = Calendar.current
        let yearStart = calendar.component(.year, from: result.concerts[0].startDate)
        XCTAssertEqual(yearStart, 2025)
    }
}

final class SearchErrorMapperTests: XCTestCase {
    private var sut: SearchErrorMapper!
    
    override func setUp() {
        super.setUp()
        sut = SearchErrorMapper()
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    func test_기본_네트워크_에러가_SearchError로_변환되어야_한다() {
        XCTAssertEqual(sut.mapToSearchError(NetworkError.noConnection(NSError(domain: "", code: -1))), .noConnection)
        XCTAssertEqual(sut.mapToSearchError(NetworkError.serverError(message: nil)), .serverError)
        XCTAssertEqual(sut.mapToSearchError(NetworkError.noData), .noSearchResult)
        XCTAssertEqual(sut.mapToSearchError(NetworkError.invalidRequest), .invalidResponse)
    }
    
    func test_메시지가_있는_에러는_해당_메시지에_매핑되는_SearchError로_변환되어야_한다() {
        let testCases: [(NetworkError, SearchError)] = [
            (.badRequest(message: "genre는 JPOP | ROCK_METAL | RAP_HIPHOP | CLASSIC_JAZZ | ACOUSTIC | ELECTRONIC | ALL 중 하나여야 해요"), .invalidGenre),
            (.badRequest(message: "status는 ONGOING | UPCOMING | COMPLETED | ALL 중 하나여야 해요"), .invalidStatus),
            (.badRequest(message: "sort는 LATEST | ALPHABETICAL 중 하나여야 해요"), .invalidSort),
            (.badRequest(message: "size must be a positive number"), .invalidSize),
            (.badRequest(message: "size must not be less than 1"), .invalidSize),
            (.badRequest(message: "유효하지 않은 cursor 형식입니다."), .invalidCursor),
            (.badRequest(message: "id must not be less than 1"), .invalidID),
            (.badRequest(message: "검색어(letter)는 필수입니다."), .missingKeyword)
        ]
        
        testCases.forEach { networkError, expectedError in
            XCTAssertEqual(sut.mapToSearchError(networkError), expectedError, "Failed for error: \(networkError)")
        }
    }
    
    func test_취소_에러는_cancelled로_변환되어야_한다() {
        XCTAssertEqual(sut.mapToSearchError(CancellationError()), .cancelled)
        XCTAssertEqual(sut.mapToSearchError(URLError(.cancelled)), .cancelled)
        XCTAssertEqual(sut.mapToSearchError(NetworkError.unknown(URLError(.cancelled))), .cancelled)
    }
}
