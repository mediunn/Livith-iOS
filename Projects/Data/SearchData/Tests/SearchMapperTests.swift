//
//  SearchMapperTests.swift
//  DataTests
//
//  Created by 김진웅 on 1/21/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation
import Testing

import LivithNetwork
import Domain
@testable import SearchData

@Suite("SearchMapper 테스트")
struct SearchMapperTests {
    let sut = SearchMapper()

    @Test("FetchBannerList DTO가 Banner Entity 목록으로 변환되어야 한다")
    func fetchBannerListDTO를BannerEntityList로변환해야한다() throws {
        // Given
        let json = """
        [
            {
              "id": 1,
              "title": "라이빗 인스타그램 운영 중!",
              "category": "@livith_concert",
              "imgUrl": "https://github.com/mediunn/Livith-Assets/blob/main/banner/instagram.png?raw=true",
              "content": "인스타에서 아티스트 릴스, 숨겨진 비하인드 이야기, \\n떼창 가이드 등 다양한 컨텐츠를 확인해 보세요!",
              "linkUrl": "https://www.instagram.com/livith_concert"
            },
            {
              "id": 2,
              "title": "팀 라이빗의 이야기가 궁금하다면?",
              "category": "라이빗 팀블로그",
              "imgUrl": "https://github.com/mediunn/Livith-Assets/blob/main/banner/tistory.png?raw=true",
              "content": "라이빗 서비스를 만들어가는 팀 라이빗의 이야기가 궁금하다면? \\n티스토리에서 라이빗을 검색해보세요!",
              "linkUrl": "https://livith.tistory.com"
            }
        ]
        """.data(using: .utf8)!
        let dto = try JSONDecoder().decode(DTO.Response.FetchBannerList.self, from: json)

        // When
        let result = sut.toDomain(from: dto)

        // Then
        #expect(result.count == 2)
        #expect(result[0].id == 1)
        #expect(result[0].title == "라이빗 인스타그램 운영 중!")
        #expect(result[0].category == "@livith_concert")
        #expect(result[0].imageURL?.absoluteString == "https://github.com/mediunn/Livith-Assets/blob/main/banner/instagram.png?raw=true")
        #expect(result[0].linkURL?.absoluteString == "https://www.instagram.com/livith_concert")
        #expect(result[0].description.contains("인스타에서 아티스트 릴스"))
        #expect(result[1].id == 2)
        #expect(result[1].title == "팀 라이빗의 이야기가 궁금하다면?")
        #expect(result[1].category == "라이빗 팀블로그")
        #expect(result[1].imageURL?.absoluteString == "https://github.com/mediunn/Livith-Assets/blob/main/banner/tistory.png?raw=true")
        #expect(result[1].linkURL?.absoluteString == "https://livith.tistory.com")
        #expect(result[1].description.contains("티스토리에서 라이빗을 검색해보세요!"))
    }

    @Test("FetchBannerList 전체 응답은 BaseResponse data로 디코딩되어야 한다")
    func fetchBannerList전체응답은BaseResponseData로디코딩되어야한다() throws {
        // Given
        let json = """
        {
          "message": "요청에 성공하였습니다.",
          "data": [
            {
              "id": 1,
              "title": "라이빗 인스타그램 운영 중!",
              "category": "@livith_concert",
              "imgUrl": "https://github.com/mediunn/Livith-Assets/blob/main/banner/instagram.png?raw=true",
              "content": "인스타에서 아티스트 릴스, 숨겨진 비하인드 이야기, \\n떼창 가이드 등 다양한 컨텐츠를 확인해 보세요!",
              "linkUrl": "https://www.instagram.com/livith_concert"
            }
          ],
          "statusCode": 200
        }
        """.data(using: .utf8)!

        // When
        let result = try JSONDecoder().decode(BaseResponse<DTO.Response.FetchBannerList>.self, from: json)

        // Then
        #expect(result.statusCode == 200)
        #expect(result.data?.count == 1)
        #expect(result.data?.first?.linkURL == "https://www.instagram.com/livith_concert")
    }

    @Test("배너 링크는 https와 host가 있을 때만 URL로 매핑되어야 한다")
    func 배너링크는Https와Host가있을때만URL로매핑되어야한다() throws {
        // Given
        let json = """
        [
            {
              "id": 1,
              "title": "유효한 링크",
              "category": "외부 링크",
              "imgUrl": "https://example.com/image.png",
              "content": "https 링크",
              "linkUrl": "https://www.instagram.com/livith_concert"
            },
            {
              "id": 2,
              "title": "커스텀 스킴",
              "category": "외부 링크",
              "imgUrl": "https://example.com/image.png",
              "content": "커스텀 스킴 링크",
              "linkUrl": "instagram://user?username=livith_concert"
            },
            {
              "id": 3,
              "title": "host 없는 링크",
              "category": "외부 링크",
              "imgUrl": "https://example.com/image.png",
              "content": "host 없는 링크",
              "linkUrl": "https:///invalid"
            },
            {
              "id": 4,
              "title": "http 링크",
              "category": "외부 링크",
              "imgUrl": "https://example.com/image.png",
              "content": "http 링크",
              "linkUrl": "http://example.com"
            },
            {
              "id": 5,
              "title": "빈 링크",
              "category": "외부 링크",
              "imgUrl": "https://example.com/image.png",
              "content": "빈 링크",
              "linkUrl": ""
            },
            {
              "id": 6,
              "title": "null 링크",
              "category": "외부 링크",
              "imgUrl": "https://example.com/image.png",
              "content": "null 링크",
              "linkUrl": null
            },
            {
              "id": 7,
              "title": "누락된 링크",
              "category": "외부 링크",
              "imgUrl": "https://example.com/image.png",
              "content": "누락된 링크"
            }
        ]
        """.data(using: .utf8)!
        let dto = try JSONDecoder().decode(DTO.Response.FetchBannerList.self, from: json)

        // When
        let result = sut.toDomain(from: dto)

        // Then
        #expect(result[0].linkURL?.absoluteString == "https://www.instagram.com/livith_concert")
        #expect(result[1].linkURL == nil)
        #expect(result[2].linkURL == nil)
        #expect(result[3].linkURL == nil)
        #expect(result[4].linkURL == nil)
        #expect(result[5].linkURL == nil)
        #expect(result[6].linkURL == nil)
    }

    @Test("FetchFilterSearchResult DTO가 SearchResult Entity로 변환되어야 한다")
    func fetchFilterSearchResultDTO를SearchResultEntity로변환해야한다() throws {
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
          "cursor": 1,
          "totalCount": 5
        }
        """.data(using: .utf8)!
        let dto = try JSONDecoder().decode(DTO.Response.FetchFilterSearchResult.self, from: json)

        // When
        let result = sut.toDomain(from: dto)

        // Then
        #expect(result.concerts.count == 3)
        #expect(result.concerts[0].title == "Ariana Grande Live in Tokyo2")
        #expect(result.concerts[0].status == .upcoming)
        #expect(result.cursor == 1)
        #expect(result.totalCount == 5)

        let yearStart = Calendar.current.component(.year, from: result.concerts[0].startDate)
        #expect(yearStart == 2025)
    }
}

@Suite("SearchErrorMapper 테스트")
struct SearchErrorMapperTests {
    let sut = SearchErrorMapper()

    @Test("기본 네트워크 에러가 SearchError로 변환되어야 한다")
    func 기본네트워크에러가SearchError로변환되어야한다() {
        #expect(sut.mapToSearchError(NetworkError.noConnection(NSError(domain: "", code: -1))) == .noConnection)
        #expect(sut.mapToSearchError(NetworkError.serverError(message: nil)) == .serverError)
        #expect(sut.mapToSearchError(NetworkError.noData) == .noSearchResult)
        #expect(sut.mapToSearchError(NetworkError.invalidRequest) == .invalidResponse)
    }

    @Test("메시지가 있는 에러는 해당 메시지에 매핑되는 SearchError로 변환되어야 한다")
    func 메시지가있는에러는해당메시지에매핑되는SearchError로변환되어야한다() {
        let testCases: [(NetworkError, SearchError)] = [
            (.badRequest(message: "genre는 JPOP | ROCK_METAL | RAP_HIPHOP | POP | INDIE | ALL 중 하나여야 해요"), .invalidGenre),
            (.badRequest(message: "status는 ONGOING | UPCOMING | COMPLETED | CANCELED | ALL 중 하나여야 해요"), .invalidStatus),
            (.badRequest(message: "sort는 LATEST | ALPHABETICAL 중 하나여야 해요"), .invalidSort),
            (.badRequest(message: "size must be a positive number"), .invalidSize),
            (.badRequest(message: "size must not be less than 1"), .invalidSize),
            (.badRequest(message: "콘서트를 찾을 수 없어요."), .invalidCursor),
            (.badRequest(message: "id must not be less than 1"), .invalidID),
            (.badRequest(message: "검색어(letter)는 필수입니다."), .missingKeyword)
        ]

        testCases.forEach { networkError, expectedError in
            #expect(sut.mapToSearchError(networkError) == expectedError, "Failed for error: \(networkError)")
        }
    }

    @Test("취소 에러는 cancelled로 변환되어야 한다")
    func 취소에러는Cancelled로변환되어야한다() {
        #expect(sut.mapToSearchError(CancellationError()) == .cancelled)
        #expect(sut.mapToSearchError(URLError(.cancelled)) == .cancelled)
        #expect(sut.mapToSearchError(NetworkError.unknown(URLError(.cancelled))) == .cancelled)
    }
}
