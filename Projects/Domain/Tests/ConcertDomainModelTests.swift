//
//  ConcertDomainModelTests.swift
//  DomainTests
//
//  Created by 김진웅 on 4/29/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation
import Testing

@testable import Domain

struct ConcertDomainModelTests {
    @Test("Concert nullable 공통 필드를 nil로 유지해야 한다")
    func concert_nullable_공통_필드를_nil로_유지해야_한다() {
        // Given
        let concert = Concert(
            id: 1,
            title: nil,
            artist: "Taylor Swift",
            status: .upcoming,
            daysLeft: nil,
            startDate: nil,
            endDate: nil,
            posterURL: nil,
            venue: nil,
            ticketSite: nil,
            ticketURL: nil,
            introduction: "테일러 스위프트의 첫 내한!",
            label: nil
        )

        // Then
        #expect(concert.id == 1)
        #expect(concert.title == nil)
        #expect(concert.daysLeft == nil)
        #expect(concert.startDate == nil)
        #expect(concert.endDate == nil)
        #expect(concert.posterURL == nil)
        #expect(concert.venue == nil)
        #expect(concert.artist == "Taylor Swift")
        #expect(concert.status == .upcoming)
        #expect(concert.introduction == "테일러 스위프트의 첫 내한!")
    }

    @Test("InterestConcert는 예매 일정을 Concert 밖에 보관해야 한다")
    func interestConcert는_예매_일정을_Concert_밖에_보관해야_한다() {
        // Given
        let preSaleDate = Date(timeIntervalSince1970: 1_761_479_200)
        let concert = makeConcert()
        let ticketingSchedule = InterestConcertTicketingSchedule(
            preSaleDate: preSaleDate,
            generalSaleDate: nil
        )

        // When
        let interestConcert = InterestConcert(
            concert: concert,
            ticketingSchedule: ticketingSchedule
        )

        // Then
        #expect(interestConcert.id == concert.id)
        #expect(interestConcert.concert.id == concert.id)
        #expect(interestConcert.ticketingSchedule.preSaleDate == preSaleDate)
        #expect(interestConcert.ticketingSchedule.generalSaleDate == nil)
    }

    @Test("InterestConcertListFilter all은 모든 조회 조건을 생략해야 한다")
    func interestConcertListFilter_all은_모든_조회_조건을_생략해야_한다() {
        // When
        let filter = InterestConcertListFilter.all

        // Then
        #expect(filter.sort == nil)
        #expect(filter.limit == nil)
        #expect(filter.nextToken == nil)
    }

    @Test("InterestConcertListFilter는 홈 섹션 조회 조건을 제공해야 한다")
    func interestConcertListFilter는_홈_섹션_조회_조건을_제공해야_한다() {
        // When
        let filter = InterestConcertListFilter.homeSection()

        // Then
        #expect(filter.sort == .ticketing)
        #expect(filter.limit == 5)
        #expect(filter.nextToken == nil)
    }

    @Test("ListResult는 관심 콘서트 목록과 다음 token을 보관해야 한다")
    func listResult는_관심_콘서트_목록과_다음_token을_보관해야_한다() {
        // Given
        let nextToken = TestNextToken()
        let interestConcert = InterestConcert(
            concert: makeConcert(),
            ticketingSchedule: InterestConcertTicketingSchedule(preSaleDate: nil, generalSaleDate: nil)
        )

        // When
        let result = ListResult(
            items: [interestConcert],
            nextToken: nextToken
        )

        // Then
        #expect(result.items.count == 1)
        #expect(result.items[0].id == interestConcert.id)
        #expect(result.nextToken != nil)
    }
}

private struct TestNextToken: NextToken {}

private extension ConcertDomainModelTests {
    func makeConcert() -> Concert {
        return Concert(
            id: 1,
            title: "Taylor Swift | The Eras Tour2",
            artist: "Taylor Swift",
            status: .upcoming,
            daysLeft: -6,
            startDate: Date(timeIntervalSince1970: 1_754_760_000),
            endDate: Date(timeIntervalSince1970: 1_754_760_000),
            posterURL: URL(string: "https://example.com/poster.png"),
            venue: "고척스카이돔",
            ticketSite: "Ticketmaster",
            ticketURL: URL(string: "https://www.ticketmaster.com/taylor-swift-tickets/artist/1094215"),
            introduction: "테일러 스위프트의 첫 내한!",
            label: "많이 찾는 콘서트 1위"
        )
    }
}
