//
//  ConcertDisplayTextTests.swift
//  DisplaySupportTests
//
//  Created by 김진웅 on 4/29/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

import DisplaySupport
import Domain

import Testing

struct ConcertDisplayTextTests {
    @Test("공연명이 없으면 아티스트 내한 예정 문구를 표시해야 한다")
    func 공연명이_없으면_아티스트_내한_예정_문구를_표시해야_한다() {
        // Given
        let concert = makeConcert(title: nil)

        // When
        let title = ConcertDisplayText.title(for: concert)

        // Then
        #expect(title == "Taylor Swift 내한 예정")
    }

    @Test("공연명이 빈 값이면 아티스트 내한 예정 문구를 표시해야 한다")
    func 공연명이_빈_값이면_아티스트_내한_예정_문구를_표시해야_한다() {
        // Given
        let concert = makeConcert(title: "  ")

        // When
        let title = ConcertDisplayText.title(for: concert)

        // Then
        #expect(title == "Taylor Swift 내한 예정")
    }

    @Test("공연장이 없으면 장소 공개 예정 문구를 표시해야 한다")
    func 공연장이_없으면_장소_공개_예정_문구를_표시해야_한다() {
        // Given
        let concert = makeConcert(venue: nil)

        // When
        let venue = ConcertDisplayText.venue(for: concert)

        // Then
        #expect(venue == "장소 공개 예정")
    }

    @Test("공연장이 빈 값이면 장소 공개 예정 문구를 표시해야 한다")
    func 공연장이_빈_값이면_장소_공개_예정_문구를_표시해야_한다() {
        // Given
        let concert = makeConcert(venue: "  ")

        // When
        let venue = ConcertDisplayText.venue(for: concert)

        // Then
        #expect(venue == "장소 공개 예정")
    }

    @Test("공연 시작일 또는 종료일이 없으면 추후 발표 문구를 표시해야 한다")
    func 공연_시작일_또는_종료일이_없으면_추후_발표_문구를_표시해야_한다() {
        // Given
        let concert = makeConcert(startDate: nil)

        // When
        let dateRange = ConcertDisplayText.dateRange(for: concert)

        // Then
        #expect(dateRange == "추후 발표")
    }

    @Test("D-day가 없으면 공연 예정 문구를 표시해야 한다")
    func dday가_없으면_공연_예정_문구를_표시해야_한다() {
        // Given
        let concert = makeConcert(daysLeft: nil)

        // When
        let daysLeft = ConcertDisplayText.daysLeft(for: concert)

        // Then
        #expect(daysLeft == "공연 예정")
    }

    @Test("카드 배지는 D-day가 없으면 공연 예정 문구를 표시해야 한다")
    func 카드_배지는_dday가_없으면_공연_예정_문구를_표시해야_한다() {
        // Given
        let concert = makeConcert(daysLeft: nil)

        // When
        let badge = ConcertDisplayText.statusBadge(for: concert)

        // Then
        #expect(badge == "공연 예정")
    }

    @Test("카드 배지는 예정 공연의 D-day가 있으면 D-day 문구를 표시해야 한다")
    func 카드_배지는_예정_공연의_dday가_있으면_dday_문구를_표시해야_한다() {
        // Given
        let concert = makeConcert(daysLeft: 7)

        // When
        let badge = ConcertDisplayText.statusBadge(for: concert)

        // Then
        #expect(badge == "D-7")
    }

    @Test("카드 배지는 예정 공연이 아니면 상태 문구를 표시해야 한다")
    func 카드_배지는_예정_공연이_아니면_상태_문구를_표시해야_한다() {
        // Given
        let concert = makeConcert(status: .completed, daysLeft: nil)

        // When
        let badge = ConcertDisplayText.statusBadge(for: concert)

        // Then
        #expect(badge == "종료")
    }

    @Test("D-day가 0이면 진행중 문구를 표시해야 한다")
    func dday가_0이면_진행중_문구를_표시해야_한다() {
        // Given
        let concert = makeConcert(daysLeft: 0)

        // When
        let daysLeft = ConcertDisplayText.daysLeft(for: concert)

        // Then
        #expect(daysLeft == "진행중")
    }

    @Test("카드 배지는 예정 공연의 D-day가 0이면 진행중 문구를 표시해야 한다")
    func 카드_배지는_예정_공연의_dday가_0이면_진행중_문구를_표시해야_한다() {
        // Given
        let concert = makeConcert(status: .upcoming, daysLeft: 0)

        // When
        let badge = ConcertDisplayText.statusBadge(for: concert)

        // Then
        #expect(badge == "진행중")
    }

    @Test("D-day가 양수이면 D-day 문구를 표시해야 한다")
    func dday가_양수이면_dday_문구를_표시해야_한다() {
        // Given
        let concert = makeConcert(daysLeft: 7)

        // When
        let daysLeft = ConcertDisplayText.daysLeft(for: concert)

        // Then
        #expect(daysLeft == "D-7")
    }

    @Test("예매 일정이 없으면 예매 오픈 예정 문구를 표시해야 한다")
    func 예매_일정이_없으면_예매_오픈_예정_문구를_표시해야_한다() {
        // When
        let ticketingDate = ConcertDisplayText.ticketingDate(nil)

        // Then
        #expect(ticketingDate == "예매 오픈 예정")
    }
}

private extension ConcertDisplayTextTests {
    func makeConcert(
        title: String? = "Taylor Swift | The Eras Tour",
        status: ConcertStatus = .upcoming,
        daysLeft: Int? = 10,
        startDate: Date? = Date(timeIntervalSince1970: 1_754_760_000),
        endDate: Date? = Date(timeIntervalSince1970: 1_754_760_000),
        venue: String? = "고척스카이돔"
    ) -> Concert {
        return Concert(
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
        )
    }
}
