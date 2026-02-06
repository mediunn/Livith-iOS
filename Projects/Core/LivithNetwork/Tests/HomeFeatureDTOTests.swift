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
}
