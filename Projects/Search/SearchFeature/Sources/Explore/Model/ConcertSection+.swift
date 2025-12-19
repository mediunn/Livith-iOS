//
//  ConcertSection+.swift
//  SearchFeature
//
//  Created by 김진웅 on 12/19/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import Foundation

import SearchDomain

extension ConcertSection {
    static var mocks: [Self] {
        let poster = URL(string: "https://fastly.picsum.photos/id/1074/108/158.jpg?hmac=Sn9-gBGPLl-20dRH7ZZ35sZOsAtEISWmitPKGuXkXQo")!

        let popular: [ConcertEntity] = [
            ConcertEntity(
                id: 101,
                title: "IU H.E.R. Encore",
                artist: "아이유",
                status: .ongoing,
                daysLeft: 0,
                startDate: "2025-12-20",
                endDate: "2025-12-21",
                posterURL: poster,
                venue: "KSPO DOME",
                ticketSite: "인터파크",
                ticketURL: URL(string: "https://example.com/ticket/iu"),
                introduction: "아이유 연말 앙코르 콘서트",
                label: "HOT"
            ),
            ConcertEntity(
                id: 102,
                title: "BLACKPINK WORLD TOUR [BORN PINK]",
                artist: "블랙핑크",
                status: .upcoming,
                daysLeft: 7,
                startDate: "2026-01-05",
                endDate: "2026-01-06",
                posterURL: poster,
                venue: "고척스카이돔",
                ticketSite: "예스24",
                ticketURL: URL(string: "https://example.com/ticket/bp"),
                introduction: "블랙핑크 월드투어 서울 스페셜",
                label: "추천"
            ),
            ConcertEntity(
                id: 103,
                title: "SEVENTEEN TOUR ‘FOLLOW’",
                artist: "세븐틴",
                status: .upcoming,
                daysLeft: 12,
                startDate: "2026-01-10",
                endDate: "2026-01-11",
                posterURL: poster,
                venue: "잠실종합운동장 주경기장",
                ticketSite: "인터파크",
                ticketURL: URL(string: "https://example.com/ticket/svt"),
                introduction: "세븐틴 투어 서울",
                label: nil
            ),
            ConcertEntity(
                id: 104,
                title: "NCT NATION : To The World",
                artist: "NCT",
                status: .completed,
                daysLeft: 0,
                startDate: "2025-10-03",
                endDate: "2025-10-04",
                posterURL: poster,
                venue: "인천 아시아드주경기장",
                ticketSite: nil,
                ticketURL: nil,
                introduction: "NCT 합동 콘서트",
                label: nil
            ),
            ConcertEntity(
                id: 105,
                title: "BTS MAP OF THE SOUL",
                artist: "방탄소년단",
                status: .upcoming,
                daysLeft: 30,
                startDate: "2026-01-30",
                endDate: "2026-01-31",
                posterURL: poster,
                venue: "서울 올림픽 주경기장",
                ticketSite: "예스24",
                ticketURL: URL(string: "https://example.com/ticket/bts"),
                introduction: "BTS 월드투어 서울",
                label: nil
            ),
            ConcertEntity(
                id: 106,
                title: "Stray Kids 2nd Tour",
                artist: "스트레이 키즈",
                status: .upcoming,
                daysLeft: 40,
                startDate: "2026-02-10",
                endDate: "2026-02-11",
                posterURL: poster,
                venue: "고척스카이돔",
                ticketSite: "인터파크",
                ticketURL: URL(string: "https://example.com/ticket/straykids"),
                introduction: "스트레이 키즈 월드투어",
                label: nil
            ),
            ConcertEntity(
                id: 107,
                title: "TWICE 4th World Tour",
                artist: "트와이스",
                status: .upcoming,
                daysLeft: 55,
                startDate: "2026-03-15",
                endDate: "2026-03-16",
                posterURL: poster,
                venue: "잠실종합운동장 주경기장",
                ticketSite: "예스24",
                ticketURL: URL(string: "https://example.com/ticket/twice"),
                introduction: "트와이스 월드 투어 서울",
                label: "추천"
            )
        ]

        let latest: [ConcertEntity] = [
            ConcertEntity(
                id: 201,
                title: "NewJeans Fan Concert",
                artist: "뉴진스",
                status: .ongoing,
                daysLeft: 0,
                startDate: "2025-12-18",
                endDate: "2025-12-20",
                posterURL: poster,
                venue: "올림픽공원 체조경기장",
                ticketSite: "예스24",
                ticketURL: URL(string: "https://example.com/ticket/nj"),
                introduction: "뉴진스 팬 콘서트",
                label: "NEW"
            ),
            ConcertEntity(
                id: 202,
                title: "AKMU CONCERT [HAPPENING]",
                artist: "악동뮤지션",
                status: .upcoming,
                daysLeft: 3,
                startDate: "2025-12-22",
                endDate: "2025-12-22",
                posterURL: poster,
                venue: "세종문화회관",
                ticketSite: "인터파크",
                ticketURL: URL(string: "https://example.com/ticket/akmu"),
                introduction: "AKMU 겨울 콘서트",
                label: nil
            ),
            ConcertEntity(
                id: 203,
                title: "MeloMance Winter Tour",
                artist: "멜로망스",
                status: .upcoming,
                daysLeft: 9,
                startDate: "2025-12-28",
                endDate: "2025-12-28",
                posterURL: poster,
                venue: "부산 벡스코",
                ticketSite: nil,
                ticketURL: nil,
                introduction: "감성 발라드 겨울 투어",
                label: nil
            ),
            ConcertEntity(
                id: 204,
                title: "ATEEZ Live in Seoul",
                artist: "에이티즈",
                status: .upcoming,
                daysLeft: 5,
                startDate: "2025-12-25",
                endDate: "2025-12-26",
                posterURL: poster,
                venue: "고척스카이돔",
                ticketSite: "인터파크",
                ticketURL: URL(string: "https://example.com/ticket/ateez"),
                introduction: "에이티즈 연말 콘서트",
                label: nil
            ),
            ConcertEntity(
                id: 205,
                title: "ITZY SHOWCASE",
                artist: "있지",
                status: .upcoming,
                daysLeft: 11,
                startDate: "2026-01-02",
                endDate: "2026-01-02",
                posterURL: poster,
                venue: "세종문화회관",
                ticketSite: "예스24",
                ticketURL: URL(string: "https://example.com/ticket/itzy"),
                introduction: "있지 단독 공연",
                label: nil
            ),
            ConcertEntity(
                id: 206,
                title: "GOT7 Fan Meeting",
                artist: "GOT7",
                status: .upcoming,
                daysLeft: 20,
                startDate: "2026-01-15",
                endDate: "2026-01-15",
                posterURL: poster,
                venue: "올림픽공원 체조경기장",
                ticketSite: nil,
                ticketURL: nil,
                introduction: "GOT7 팬미팅",
                label: nil
            ),
            ConcertEntity(
                id: 207,
                title: "Jannabi Winter Concert",
                artist: "잔나비",
                status: .upcoming,
                daysLeft: 25,
                startDate: "2026-01-20",
                endDate: "2026-01-20",
                posterURL: poster,
                venue: "부산 벡스코",
                ticketSite: nil,
                ticketURL: nil,
                introduction: "잔나비 겨울 콘서트",
                label: nil
            )
        ]

        let recommended: [ConcertEntity] = [
            ConcertEntity(
                id: 301,
                title: "Ed Sheeran +",
                artist: "Ed Sheeran",
                status: .upcoming,
                daysLeft: 20,
                startDate: "2026-01-25",
                endDate: "2026-01-26",
                posterURL: poster,
                venue: "서울 올림픽 주경기장",
                ticketSite: "인터파크",
                ticketURL: URL(string: "https://example.com/ticket/ed"),
                introduction: "에드 쉬런 내한 공연",
                label: "추천"
            ),
            ConcertEntity(
                id: 302,
                title: "Coldplay Music of the Spheres",
                artist: "Coldplay",
                status: .upcoming,
                daysLeft: 45,
                startDate: "2026-02-10",
                endDate: "2026-02-11",
                posterURL: poster,
                venue: "부산 아시아드 주경기장",
                ticketSite: "예스24",
                ticketURL: URL(string: "https://example.com/ticket/cp"),
                introduction: "콜드플레이 내한 콘서트",
                label: nil
            ),
            ConcertEntity(
                id: 303,
                title: "ADELE: Weekends With Adele",
                artist: "Adele",
                status: .upcoming,
                daysLeft: 90,
                startDate: "2026-04-05",
                endDate: "2026-04-06",
                posterURL: poster,
                venue: "서울 고척스카이돔",
                ticketSite: nil,
                ticketURL: nil,
                introduction: "아델 단독 내한 공연",
                label: nil
            ),
            ConcertEntity(
                id: 304,
                title: "Bruno Mars Live",
                artist: "Bruno Mars",
                status: .upcoming,
                daysLeft: 60,
                startDate: "2026-03-10",
                endDate: "2026-03-10",
                posterURL: poster,
                venue: "서울 올림픽 주경기장",
                ticketSite: "예스24",
                ticketURL: URL(string: "https://example.com/ticket/bruno"),
                introduction: "브루노 마스 라이브 콘서트",
                label: nil
            ),
            ConcertEntity(
                id: 305,
                title: "Lana Del Rey Intimate",
                artist: "Lana Del Rey",
                status: .upcoming,
                daysLeft: 75,
                startDate: "2026-03-25",
                endDate: "2026-03-25",
                posterURL: poster,
                venue: "세종문화회관",
                ticketSite: nil,
                ticketURL: nil,
                introduction: "라나 델 레이 단독 공연",
                label: nil
            ),
            ConcertEntity(
                id: 306,
                title: "Dua Lipa Future Nostalgia",
                artist: "Dua Lipa",
                status: .upcoming,
                daysLeft: 90,
                startDate: "2026-04-20",
                endDate: "2026-04-21",
                posterURL: poster,
                venue: "부산 벡스코",
                ticketSite: "인터파크",
                ticketURL: URL(string: "https://example.com/ticket/dualipa"),
                introduction: "듀아 리파 내한 공연",
                label: nil
            ),
            ConcertEntity(
                id: 307,
                title: "John Legend Night",
                artist: "John Legend",
                status: .upcoming,
                daysLeft: 120,
                startDate: "2026-05-30",
                endDate: "2026-05-30",
                posterURL: poster,
                venue: "서울 고척스카이돔",
                ticketSite: nil,
                ticketURL: nil,
                introduction: "존 레전드 내한 콘서트",
                label: nil
            )
        ]

        return [
            ConcertSection(id: 1, title: "인기 콘서트", concerts: popular),
            ConcertSection(id: 2, title: "최신 콘서트", concerts: latest),
            ConcertSection(id: 3, title: "추천 콘서트", concerts: recommended)
        ]
    }
}
