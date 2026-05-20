//
//  InterestConcertDisplayTextTests.swift
//  DisplaySupportTests
//
//  Created by 김진웅 on 4/30/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

import DisplaySupport
import Domain

import Testing

@Suite("관심 콘서트 표시 문구")
struct InterestConcertDisplayTextTests {
    @Test("공연명이 없으면 아티스트 내한 예정 문구를 표시해야 한다")
    func 공연명이_없으면_아티스트_내한_예정_문구를_표시해야_한다() {
        // Given
        let interestConcert = makeInterestConcert(title: nil)

        // When
        let title = InterestConcertDisplayText.title(for: interestConcert)

        // Then
        #expect(title == "Taylor Swift 내한 예정")
    }

    @Test("공연장이 없으면 장소 공개 예정 문구를 표시해야 한다")
    func 공연장이_없으면_장소_공개_예정_문구를_표시해야_한다() {
        // Given
        let interestConcert = makeInterestConcert(venue: nil)

        // When
        let venue = InterestConcertDisplayText.venue(for: interestConcert)

        // Then
        #expect(venue == "장소 공개 예정")
    }

    @Test("공연 시작일 또는 종료일이 없으면 추후 발표 문구를 표시해야 한다")
    func 공연_시작일_또는_종료일이_없으면_추후_발표_문구를_표시해야_한다() {
        // Given
        let interestConcert = makeInterestConcert(startDate: nil)

        // When
        let dateRange = InterestConcertDisplayText.dateRange(for: interestConcert)

        // Then
        #expect(dateRange == "추후 발표")
    }

    @Test("D-day가 없으면 배지는 공연 예정 문구를 표시해야 한다")
    func dday가_없으면_배지는_공연_예정_문구를_표시해야_한다() {
        // Given
        let interestConcert = makeInterestConcert(daysLeft: nil)

        // When
        let badge = InterestConcertDisplayText.badge(for: interestConcert)

        // Then
        #expect(badge == "공연 예정")
    }

    @Test("D-day가 0이면 배지는 공연 D-DAY 문구를 표시해야 한다")
    func dday가_0이면_배지는_공연_dday_문구를_표시해야_한다() {
        // Given
        let interestConcert = makeInterestConcert(daysLeft: 0)

        // When
        let badge = InterestConcertDisplayText.badge(for: interestConcert)

        // Then
        #expect(badge == "공연 D-DAY")
    }

    @Test("D-day가 양수이면 배지는 공연 D-day 문구를 표시해야 한다")
    func dday가_양수이면_배지는_공연_dday_문구를_표시해야_한다() {
        // Given
        let interestConcert = makeInterestConcert(daysLeft: 7)

        // When
        let badge = InterestConcertDisplayText.badge(for: interestConcert)

        // Then
        #expect(badge == "공연 D-7")
    }

    @Test("D-day가 음수이면 배지는 공연 예정 문구를 표시해야 한다")
    func dday가_음수이면_배지는_공연_예정_문구를_표시해야_한다() {
        // Given
        let interestConcert = makeInterestConcert(daysLeft: -1)

        // When
        let badge = InterestConcertDisplayText.badge(for: interestConcert)

        // Then
        #expect(badge == "공연 예정")
    }

    @Test("예정 공연이 아니면 배지는 상태 문구를 표시해야 한다")
    func 예정_공연이_아니면_배지는_상태_문구를_표시해야_한다() {
        // Given
        let interestConcert = makeInterestConcert(status: .canceled)

        // When
        let badge = InterestConcertDisplayText.badge(for: interestConcert)

        // Then
        #expect(badge == "공연취소")
    }

    @Test("진행중 공연이면 배지는 공연 D-DAY 문구를 표시해야 한다")
    func 진행중_공연이면_배지는_공연_dday_문구를_표시해야_한다() {
        // Given
        let interestConcert = makeInterestConcert(status: .ongoing)

        // When
        let badge = InterestConcertDisplayText.badge(for: interestConcert)

        // Then
        #expect(badge == "공연 D-DAY")
    }

    @Test("공연 기간이 현재 시각을 포함하면 하단 문구는 콘서트 진행중을 표시해야 한다")
    func 공연_기간이_현재_시각을_포함하면_하단_문구는_콘서트_진행중을_표시해야_한다() {
        // Given
        let now = Date()
        let startDate = now.addingTimeInterval(-86400)
        let endDate = now.addingTimeInterval(86400)
        let interestConcert = makeInterestConcert(status: .upcoming, startDate: startDate, endDate: endDate, preSaleDate: pastTicketingDate, generalSaleDate: pastTicketingDate)

        // When
        let bottom = InterestConcertDisplayText.bottom(for: interestConcert)

        // Then
        #expect(bottom == "콘서트 진행중")
    }

    @Test("진행중 공연이면 하단 문구는 콘서트 진행중을 표시해야 한다")
    func 진행중_공연이면_하단_문구는_콘서트_진행중을_표시해야_한다() {
        // Given
        let interestConcert = makeInterestConcert(status: .ongoing, daysLeft: nil)

        // When
        let bottom = InterestConcertDisplayText.bottom(for: interestConcert)

        // Then
        #expect(bottom == "콘서트 진행중")
    }

    @Test("공연 기간이 미래이면 하단 문구는 콘서트 진행중을 표시하지 않아야 한다")
    func 공연_기간이_미래이면_하단_문구는_콘서트_진행중을_표시하지_않아야_한다() {
        // Given
        let now = Date()
        let startDate = now.addingTimeInterval(86400)
        let endDate = now.addingTimeInterval(172800)
        let interestConcert = makeInterestConcert(status: .upcoming, startDate: startDate, endDate: endDate, preSaleDate: nil, generalSaleDate: nil)

        // When
        let bottom = InterestConcertDisplayText.bottom(for: interestConcert)

        // Then
        #expect(bottom != "콘서트 진행중")
    }

    @Test("선예매와 일반 예매 일정이 모두 있으면 하단 문구는 더 이른 날짜를 우선 표시해야 한다")
    func 선예매와_일반_예매_일정이_모두_있으면_하단_문구는_더_이른_날짜를_우선_표시해야_한다() {
        // Given
        let interestConcert = makeInterestConcert(preSaleDate: ticketingDate, generalSaleDate: laterTicketingDate)

        // When
        let bottom = InterestConcertDisplayText.bottom(for: interestConcert)

        // Then
        #expect(bottom == "선예매 오픈 · 8/22(토) 5:30PM")
    }

    @Test("선예매 일정만 있으면 하단 문구는 선예매 오픈 문구를 표시해야 한다")
    func 선예매_일정만_있으면_하단_문구는_선예매_오픈_문구를_표시해야_한다() {
        // Given
        let interestConcert = makeInterestConcert(preSaleDate: ticketingDate, generalSaleDate: nil)

        // When
        let bottom = InterestConcertDisplayText.bottom(for: interestConcert)

        // Then
        #expect(bottom == "선예매 오픈 · 8/22(토) 5:30PM")
    }

    @Test("선예매 일정이 없고 일반 예매 일정이 있으면 하단 문구는 일반 예매 오픈 문구를 표시해야 한다")
    func 선예매_일정이_없고_일반_예매_일정이_있으면_하단_문구는_일반_예매_오픈_문구를_표시해야_한다() {
        // Given
        let interestConcert = makeInterestConcert(preSaleDate: nil, generalSaleDate: ticketingDate)

        // When
        let bottom = InterestConcertDisplayText.bottom(for: interestConcert)

        // Then
        #expect(bottom == "일반 예매 오픈 · 8/22(토) 5:30PM")
    }

    @Test("예매 일정이 없으면 하단 문구는 예매 오픈 예정 문구를 표시해야 한다")
    func 예매_일정이_없으면_하단_문구는_예매_오픈_예정_문구를_표시해야_한다() {
        // Given
        let interestConcert = makeInterestConcert(preSaleDate: nil, generalSaleDate: nil)

        // When
        let bottom = InterestConcertDisplayText.bottom(for: interestConcert)

        // Then
        #expect(bottom == "예매 오픈 예정")
    }

    @Test("D-day가 없고 예매 일정도 없으면 하단 문구는 예매 오픈 예정 문구를 표시해야 한다")
    func dday가_없고_예매_일정도_없으면_하단_문구는_예매_오픈_예정_문구를_표시해야_한다() {
        // Given
        let interestConcert = makeInterestConcert(daysLeft: nil, preSaleDate: nil, generalSaleDate: nil)

        // When
        let bottom = InterestConcertDisplayText.bottom(for: interestConcert)

        // Then
        #expect(bottom == "예매 오픈 예정")
    }

    @Test("선예매 날짜가 지났고 일반 예매 날짜만 남아있으면 일반 예매 오픈 문구를 표시해야 한다")
    func 선예매_날짜가_지났고_일반_예매_날짜만_남아있으면_일반_예매_오픈_문구를_표시해야_한다() {
        // Given
        let interestConcert = makeInterestConcert(preSaleDate: pastTicketingDate, generalSaleDate: ticketingDate)

        // When
        let bottom = InterestConcertDisplayText.bottom(for: interestConcert)

        // Then
        #expect(bottom == "일반 예매 오픈 · 8/22(토) 5:30PM")
    }

    @Test("두 예매 날짜가 모두 지났으면 하단 문구는 일반 예매 오픈 문구를 표시해야 한다")
    func 두_예매_날짜가_모두_지났으면_하단_문구는_일반_예매_오픈_문구를_표시해야_한다() {
        // Given
        let interestConcert = makeInterestConcert(preSaleDate: pastTicketingDate, generalSaleDate: pastTicketingDate)

        // When
        let bottom = InterestConcertDisplayText.bottom(for: interestConcert)

        // Then
        #expect(bottom == "일반 예매 오픈 · 1/1(목) 9:00AM")
    }
}

private extension InterestConcertDisplayTextTests {
    var pastTicketingDate: Date {
        Date(timeIntervalSince1970: 0)
    }

    var ticketingDate: Date {
        Date(timeIntervalSince1970: 1_787_387_400)
    }

    var laterTicketingDate: Date {
        Date(timeIntervalSince1970: 1_787_473_800)
    }

    func makeInterestConcert(
        title: String? = "Taylor Swift | The Eras Tour",
        status: ConcertStatus = .upcoming,
        daysLeft: Int? = 10,
        startDate: Date? = Date(timeIntervalSince1970: 1_754_760_000),
        endDate: Date? = Date(timeIntervalSince1970: 1_754_760_000),
        venue: String? = "고척스카이돔",
        preSaleDate: Date? = nil,
        generalSaleDate: Date? = nil
    ) -> InterestConcert {
        return InterestConcert(
            concert: Concert(
                id: 1,
                title: title,
                artist: "Taylor Swift",
                status: status,
                daysLeft: daysLeft,
                startDate: startDate,
                endDate: endDate,
                posterURL: URL(string: "https://example.com/poster.png"),
                venue: venue,
                ticketSite: "Ticketmaster",
                ticketURL: URL(string: "https://example.com/ticket"),
                introduction: "테일러 스위프트의 첫 내한!",
                label: nil
            ),
            ticketingSchedule: InterestConcertTicketingSchedule(
                preSaleDate: preSaleDate,
                generalSaleDate: generalSaleDate
            )
        )
    }
}
