//
//  HomeFeatureDTOTests.swift
//  LivithNetworkTests
//
//  Created by 김진웅 on 2/5/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation
import Testing

@testable import LivithNetwork

struct HomeFeatureDTOTests {
    @Test("FetchUserInterestConcert 목록 응답 디코딩이 정상적으로 되어야 한다")
    func fetchUserInterestConcert_목록_응답_디코딩이_정상적으로_되어야_한다() throws {
        // Given
        let json = """
        {
          "data": [
            {
              "id": 8,
              "code": "PF268438",
              "title": "제이크 밀러 첫 단독 내한공연 JAKE MILLER BALANCE TOUR",
              "startDate": "2025.09.27",
              "endDate": "2025.09.27",
              "status": "COMPLETED",
              "poster": "http://www.kopis.or.kr/upload/pfmPoster/PF_PF268438_250703_114113.gif",
              "artist": "JAKE MILLER (제이크 밀러)",
              "daysLeft": -16,
              "ticketSite": "NOL 티켓",
              "ticketUrl": "https://tickets.interpark.com/goods/25009244",
              "venue": "무신사 개러지",
              "introduction": "데뷔 10년 만에 드디어 한국 상륙!",
              "label": "첫 단독 내한 콘서트",
              "preSaleDate": "2025-06-15T12:00:00.000Z",
              "generalSaleDate": null
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
              "daysLeft": -6,
              "ticketSite": "Ticketmaster",
              "ticketUrl": "https://www.ticketmaster.com/taylor-swift-tickets/artist/1094215",
              "venue": "고척스카이돔",
              "introduction": "테일러 스위프트의 첫 내한!",
              "label": "많이 찾는 콘서트 1위",
              "preSaleDate": "2025-06-15T12:00:00.000Z",
              "generalSaleDate": "2025-06-20T12:00:00.000Z"
            }
          ],
          "cursor": {
            "date": "2025.08.10",
            "id": 1
          }
        }
        """.data(using: .utf8)!

        // When
        let result = try JSONDecoder().decode(DTO.Response.FetchUserInterestConcert.self, from: json)

        // Then
        #expect(result.data.count == 2)
        #expect(result.data[0].id == 8)
        #expect(result.data[0].posterURL == "http://www.kopis.or.kr/upload/pfmPoster/PF_PF268438_250703_114113.gif")
        #expect(result.data[0].preSaleDate == "2025-06-15T12:00:00.000Z")
        #expect(result.data[0].generalSaleDate == nil)
        #expect(result.data[1].id == 1)
        #expect(result.data[1].generalSaleDate == "2025-06-20T12:00:00.000Z")
        #expect(result.cursor?.date == "2025.08.10")
        #expect(result.cursor?.id == 1)
    }

    @Test("FetchUserInterestConcert BaseResponse 목록 응답 디코딩이 정상적으로 되어야 한다")
    func fetchUserInterestConcert_baseResponse_목록_응답_디코딩이_정상적으로_되어야_한다() throws {
        // Given
        let json = """
        {
          "statusCode": 200,
          "message": "요청에 성공하였습니다.",
          "data": {
            "data": [
              {
                "id": 8,
                "status": "COMPLETED",
                "artist": "JAKE MILLER (제이크 밀러)",
                "introduction": "데뷔 10년 만에 드디어 한국 상륙!"
              }
            ],
            "cursor": {
              "date": "2025.08.10",
              "id": 1
            }
          }
        }
        """.data(using: .utf8)!

        // When
        let result = try JSONDecoder().decode(BaseResponse<DTO.Response.FetchUserInterestConcert>.self, from: json)

        // Then
        #expect(result.statusCode == 200)
        #expect(result.data?.data.count == 1)
        #expect(result.data?.data[0].id == 8)
        #expect(result.data?.cursor?.date == "2025.08.10")
        #expect(result.data?.cursor?.id == 1)
    }

    @Test("FetchUserInterestConcert optional 필드가 null이거나 누락되어도 디코딩되어야 한다")
    func fetchUserInterestConcert_optional_필드가_null이거나_누락되어도_디코딩되어야_한다() throws {
        // Given
        let json = """
        {
          "data": [
            {
              "id": 8,
              "code": null,
              "title": null,
              "startDate": null,
              "endDate": null,
              "status": "COMPLETED",
              "poster": null,
              "artist": "JAKE MILLER (제이크 밀러)",
              "daysLeft": null,
              "ticketSite": null,
              "ticketUrl": null,
              "venue": null,
              "introduction": "데뷔 10년 만에 드디어 한국 상륙!",
              "label": null,
              "preSaleDate": null
            }
          ],
          "cursor": null
        }
        """.data(using: .utf8)!

        // When
        let result = try JSONDecoder().decode(DTO.Response.FetchUserInterestConcert.self, from: json)

        // Then
        #expect(result.data.count == 1)
        #expect(result.data[0].id == 8)
        #expect(result.data[0].code == nil)
        #expect(result.data[0].title == nil)
        #expect(result.data[0].startDate == nil)
        #expect(result.data[0].endDate == nil)
        #expect(result.data[0].posterURL == nil)
        #expect(result.data[0].daysLeft == nil)
        #expect(result.data[0].venue == nil)
        #expect(result.data[0].generalSaleDate == nil)
        #expect(result.cursor == nil)
    }

    @Test("FetchUserInterestConcert BaseResponse data가 null이어도 디코딩되어야 한다")
    func fetchUserInterestConcert_baseResponse_data가_null이어도_디코딩되어야_한다() throws {
        // Given
        let json = """
        {
          "statusCode": 200,
          "message": "요청에 성공하였습니다.",
          "data": null
        }
        """.data(using: .utf8)!

        // When
        let result = try JSONDecoder().decode(BaseResponse<DTO.Response.FetchUserInterestConcert>.self, from: json)

        // Then
        #expect(result.statusCode == 200)
        #expect(result.message == "요청에 성공하였습니다.")
        #expect(result.data == nil)
    }

    @Test("HomeEndpoint 관심 콘서트 목록 첫 페이지 query를 생성해야 한다")
    func homeEndpoint_관심_콘서트_목록_첫_페이지_query를_생성해야_한다() throws {
        // Given
        let request = DTO.Request.FetchInterestConcertList()

        // When
        let endpoint = HomeEndpoint.fetchInterestedConcertList(request)
        let query = try #require(endpoint.query)

        // Then
        #expect(endpoint.path == "/users/interest-concerts")
        #expect(endpoint.method == .get)
        #expect(endpoint.requiresInterceptor)
        #expect(query["sort"] as? String == "CONCERT")
        #expect(query["size"] as? Int == 20)
        #expect(query["cursorDate"] == nil)
        #expect(query["cursorId"] == nil)
    }

    @Test("HomeEndpoint 관심 콘서트 목록 다음 페이지 query를 생성해야 한다")
    func homeEndpoint_관심_콘서트_목록_다음_페이지_query를_생성해야_한다() throws {
        // Given
        let request = DTO.Request.FetchInterestConcertList(
            sort: .ticketing,
            size: 10,
            cursorDate: "2025.08.10",
            cursorID: 1
        )

        // When
        let endpoint = HomeEndpoint.fetchInterestedConcertList(request)
        let query = try #require(endpoint.query)

        // Then
        #expect(endpoint.path == "/users/interest-concerts")
        #expect(endpoint.method == .get)
        #expect(endpoint.requiresInterceptor)
        #expect(query["sort"] as? String == "TICKETING")
        #expect(query["size"] as? Int == 10)
        #expect(query["cursorDate"] as? String == "2025.08.10")
        #expect(query["cursorId"] as? Int == 1)
    }

    @Test("FetchRecommendedConcertList 디코딩이 정상적으로 되어야 한다")
    func fetchRecommendedConcertList_디코딩이_정상적으로_되어야_한다() throws {
        // Given
        let json = """
        [
            {
              "id" : 1579,
              "daysLeft" : -12,
              "label" : "",
              "introduction" : "따뜻한 감성으로 노래하는 wacci, 첫 내한 단독 콘서트 'SHOUKEI'로 한국 팬들과 특별한 만남!",
              "ticketUrl" : "https://ticket.yes24.com/Perf/55771",
              "endDate" : "2026.01.24",
              "title" : "wacci Hall Tour: SHOUKEI [서울]",
              "code" : "PF277177",
              "venue" : "예스24 원더로크홀 (예스24 원더로크홀)",
              "poster" : "http://www.kopis.or.kr/upload/pfmPoster/PF_PF277177_251023_152216.jpg",
              "startDate" : "2026.01.24",
              "ticketSite" : "예스24",
              "artist" : "wacci (와치)",
              "status" : "UPCOMING"
            },
            {
              "id" : 1613,
              "daysLeft" : 1,
              "label" : "",
              "introduction" : "Koi 신드롬의 주인공 호시노 겐, 첫 내한 5개월 만에 '약속'을 지키러 다시 한국을 찾는다!",
              "ticketUrl" : "https://tickets.interpark.com/goods/25017416",
              "endDate" : "2026.02.06",
              "title" : "호시노 겐 내한공연 (Gen Hoshino Live) : 약속 [서울]",
              "code" : "PF280805",
              "venue" : "인스파이어 엔터테인먼트 리조트 (아레나)",
              "poster" : "http://www.kopis.or.kr/upload/pfmPoster/PF_PF280805_251203_132359.gif",
              "startDate" : "2026.02.06",
              "ticketSite" : "NOL 티켓",
              "artist" : "Gen Hoshino (호시노 겐)",
              "status" : "UPCOMING"
            }
        ]
        """.data(using: .utf8)!

        // When
        let result = try JSONDecoder().decode(DTO.Response.FetchRecommendedConcertList.self, from: json)

        // Then
        #expect(result.count == 2)
        #expect(result[0].id == 1579)
        #expect(result[0].title == "wacci Hall Tour: SHOUKEI [서울]")
        #expect(result[0].ticketURL == "https://ticket.yes24.com/Perf/55771")
        #expect(result[1].id == 1613)
        #expect(result[1].title == "호시노 겐 내한공연 (Gen Hoshino Live) : 약속 [서울]")
    }

    @Test("UpdateUserInterestConcertList request는 concertIds 정수 배열로 인코딩되어야 한다")
    func updateUserInterestConcertList_request는_concertIds_정수_배열로_인코딩되어야_한다() throws {
        // Given
        let request = DTO.Request.UpdateUserInterestConcertList(concertIDList: [8, 1])

        // When
        let data = try JSONEncoder().encode(request)
        let jsonObject = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        let concertIDList = try #require(jsonObject?["concertIds"] as? [Int])

        // Then
        #expect(concertIDList == [8, 1])
    }

    @Test("HomeEndpoint 관심 콘서트 목록 설정 수정 endpoint를 생성해야 한다")
    func homeEndpoint_관심_콘서트_목록_설정_수정_endpoint를_생성해야_한다() throws {
        // Given
        let request = DTO.Request.UpdateUserInterestConcertList(concertIDList: [8, 1])

        // When
        let endpoint = HomeEndpoint.updateInterestedConcertList(request: request)

        // Then
        #expect(endpoint.path == "/users/interest-concerts")
        #expect(endpoint.method == .put)
        #expect(endpoint.body != nil)
        #expect(endpoint.requiresInterceptor)
    }

    @Test("UpdateUserInterestConcertList 응답은 optional 필드가 누락되어도 디코딩되어야 한다")
    func updateUserInterestConcertList_응답은_optional_필드가_누락되어도_디코딩되어야_한다() throws {
        // Given
        let json = """
        [
            {
                "id": 8,
                "status": "COMPLETED",
                "artist": "JAKE MILLER (제이크 밀러)",
                "introduction": "첫 단독 내한 공연"
            }
        ]
        """.data(using: .utf8)!

        // When
        let result = try JSONDecoder().decode(DTO.Response.UpdateUserInterestConcertList.self, from: json)

        // Then
        let concert = try #require(result.first)
        #expect(concert.id == 8)
        #expect(concert.title == nil)
        #expect(concert.startDate == nil)
        #expect(concert.posterURL == nil)
        #expect(concert.artist == "JAKE MILLER (제이크 밀러)")
    }
}
