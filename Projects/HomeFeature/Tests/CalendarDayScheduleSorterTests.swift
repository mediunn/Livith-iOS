//
//  CalendarDayScheduleSorterTests.swift
//  HomeFeatureTests
//
//  Created by 김진웅 on 7/19/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Testing

@testable import HomeFeature

@Suite("CalendarDayScheduleSorter")
struct CalendarDayScheduleSorterTests {

    @Test("시간 있는 항목은 시각 오름차순으로 정렬되어야 한다")
    func 시간_있는_항목은_시각_오름차순으로_정렬되어야_한다() {
        // Given
        let later = makeItem(id: "2", title: "B", time: .init(hour: 20, minute: 0))
        let earlier = makeItem(id: "1", title: "A", time: .init(hour: 18, minute: 0))

        // When
        let result = CalendarDayScheduleSorter.sorted([later, earlier])

        // Then
        #expect(result.map(\.id) == ["1", "2"])
    }

    @Test("동일 시각이면 공연명 가나다 순으로 정렬되어야 한다")
    func 동일_시각이면_공연명_가나다_순으로_정렬되어야_한다() {
        // Given
        let zebra = makeItem(id: "z", title: "위켄드", time: .init(hour: 18, minute: 0))
        let apple = makeItem(id: "a", title: "아이유", time: .init(hour: 18, minute: 0))

        // When
        let result = CalendarDayScheduleSorter.sorted([zebra, apple])

        // Then
        #expect(result.map(\.id) == ["a", "z"])
    }

    @Test("시간 없는 항목은 시간 있는 항목 뒤에 정렬되어야 한다")
    func 시간_없는_항목은_시간_있는_항목_뒤에_정렬되어야_한다() {
        // Given
        let tba = makeItem(id: "tba", title: "추후", time: nil)
        let timed = makeItem(id: "t", title: "일정", time: .init(hour: 18, minute: 0))

        // When
        let result = CalendarDayScheduleSorter.sorted([tba, timed])

        // Then
        #expect(result.map(\.id) == ["t", "tba"])
    }

    @Test("취소 항목은 최하단에 정렬되어야 한다")
    func 취소_항목은_최하단에_정렬되어야_한다() {
        // Given
        let cancelled = makeItem(id: "c", title: "취소공연", time: .init(hour: 10, minute: 0), isCancelled: true)
        let tba = makeItem(id: "tba", title: "추후", time: nil)
        let timed = makeItem(id: "t", title: "일정", time: .init(hour: 18, minute: 0))

        // When
        let result = CalendarDayScheduleSorter.sorted([cancelled, tba, timed])

        // Then
        #expect(result.map(\.id) == ["t", "tba", "c"])
    }

    @Test("취소 항목은 시간 유무와 무관하게 최하단에 정렬되어야 한다")
    func 취소_항목은_시간_유무와_무관하게_최하단에_정렬되어야_한다() {
        // Given
        let cancelledWithoutTime = makeItem(id: "c", title: "취소", time: nil, isCancelled: true)
        let tba = makeItem(id: "tba", title: "추후", time: nil)

        // When
        let result = CalendarDayScheduleSorter.sorted([cancelledWithoutTime, tba])

        // Then
        #expect(result.map(\.id) == ["tba", "c"])
    }
}

// MARK: - Helpers

private extension CalendarDayScheduleSorterTests {
    func makeItem(
        id: String,
        title: String,
        time: CalendarDayScheduleItem.Time?,
        isCancelled: Bool = false
    ) -> CalendarDayScheduleItem {
        CalendarDayScheduleItem(
            id: id,
            kind: .ticketing,
            title: title,
            subtitle: "NOL 티켓",
            time: time,
            isCancelled: isCancelled
        )
    }
}
