//
//  CalendarDayScheduleSorterTests.swift
//  HomeFeatureTests
//
//  Created by 김진웅 on 7/19/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Testing

import Domain

@testable import HomeFeature

@Suite("CalendarDayScheduleSorter")
struct CalendarDayScheduleSorterTests {

    @Test("시간 있는 항목은 시각 오름차순으로 정렬되어야 한다")
    func 시간_있는_항목은_시각_오름차순으로_정렬되어야_한다() {
        // Given
        let later = makeEvent(concertID: 2, title: "B", time: .init(hour: 20, minute: 0))
        let earlier = makeEvent(concertID: 1, title: "A", time: .init(hour: 18, minute: 0))

        // When
        let result = CalendarDayScheduleSorter.sorted([later, earlier])

        // Then
        #expect(result.map(\.concertID) == [1, 2])
    }

    @Test("동일 시각이면 공연명 가나다 순으로 정렬되어야 한다")
    func 동일_시각이면_공연명_가나다_순으로_정렬되어야_한다() {
        // Given
        let zebra = makeEvent(concertID: 2, title: "위켄드", time: .init(hour: 18, minute: 0))
        let apple = makeEvent(concertID: 1, title: "아이유", time: .init(hour: 18, minute: 0))

        // When
        let result = CalendarDayScheduleSorter.sorted([zebra, apple])

        // Then
        #expect(result.map(\.concertID) == [1, 2])
    }

    @Test("시간 없는 항목은 시간 있는 항목 뒤에 정렬되어야 한다")
    func 시간_없는_항목은_시간_있는_항목_뒤에_정렬되어야_한다() {
        // Given
        let tba = makeEvent(concertID: 2, title: "추후", time: nil)
        let timed = makeEvent(concertID: 1, title: "일정", time: .init(hour: 18, minute: 0))

        // When
        let result = CalendarDayScheduleSorter.sorted([tba, timed])

        // Then
        #expect(result.map(\.concertID) == [1, 2])
    }

    @Test("취소 항목은 최하단에 정렬되어야 한다")
    func 취소_항목은_최하단에_정렬되어야_한다() {
        // Given
        let cancelled = makeEvent(
            concertID: 3,
            title: "취소공연",
            time: .init(hour: 10, minute: 0),
            status: .cancelled
        )
        let tba = makeEvent(concertID: 2, title: "추후", time: nil)
        let timed = makeEvent(concertID: 1, title: "일정", time: .init(hour: 18, minute: 0))

        // When
        let result = CalendarDayScheduleSorter.sorted([cancelled, tba, timed])

        // Then
        #expect(result.map(\.concertID) == [1, 2, 3])
    }

    @Test("취소 항목은 시간 유무와 무관하게 최하단에 정렬되어야 한다")
    func 취소_항목은_시간_유무와_무관하게_최하단에_정렬되어야_한다() {
        // Given
        let cancelledWithoutTime = makeEvent(
            concertID: 2,
            title: "취소",
            time: nil,
            status: .cancelled
        )
        let tba = makeEvent(concertID: 1, title: "추후", time: nil)

        // When
        let result = CalendarDayScheduleSorter.sorted([cancelledWithoutTime, tba])

        // Then
        #expect(result.map(\.concertID) == [1, 2])
    }
}

// MARK: - Helpers

private extension CalendarDayScheduleSorterTests {
    func makeEvent(
        concertID: Int,
        title: String,
        time: CalendarEventTime?,
        status: CalendarDayEventStatus = .upcoming,
        type: CalendarDayEventType = .generalTicketing
    ) -> CalendarDayEvent {
        CalendarDayEvent(
            concertID: concertID,
            title: title,
            type: type,
            status: status,
            time: time,
            detail: .ticketOffice("NOL 티켓")
        )
    }
}
