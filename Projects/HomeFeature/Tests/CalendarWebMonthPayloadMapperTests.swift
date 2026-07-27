//
//  CalendarWebMonthPayloadMapperTests.swift
//  HomeFeatureTests
//
//  Created by 김진웅 on 7/24/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation
import Testing

import Domain
import LivithFoundation

@testable import HomeFeature

@Suite("CalendarWebMonthPayloadMapper")
struct CalendarWebMonthPayloadMapperTests {

    @Test("월 데이터를 day 배열 JSON으로 직렬화해야 한다")
    func 월_데이터를_day_배열_JSON으로_직렬화해야_한다() throws {
        // Given
        let date = try #require(DateFormatterService.date(from: "2026-07-22", type: .dashDate))
        let month = CalendarMonth(
            dayList: [
                CalendarMonthDay(
                    date: date,
                    eventList: [
                        CalendarMonthEvent(concertID: 1, artist: "Coldplay", type: .concert)
                    ]
                )
            ]
        )

        // When
        let jsonString = try #require(CalendarWebMonthPayloadMapper.jsonString(from: month))
        let data = try #require(jsonString.data(using: .utf8))
        let days = try #require(JSONSerialization.jsonObject(with: data) as? [[String: Any]])

        // Then
        #expect(days.count == 1)
        #expect(days[0]["date"] as? String == "2026-07-22")
        let events = try #require(days[0]["events"] as? [[String: Any]])
        #expect(events.count == 1)
        #expect(events[0]["id"] as? Int == 1)
        #expect(events[0]["artist"] as? String == "Coldplay")
        #expect(events[0]["type"] as? String == "CONCERT")
    }

    @Test("빈 dayList면 빈 배열을 직렬화해야 한다")
    func 빈_dayList면_빈_배열을_직렬화해야_한다() throws {
        // Given
        let month = CalendarMonth(dayList: [])

        // When
        let jsonString = try #require(CalendarWebMonthPayloadMapper.jsonString(from: month))
        let data = try #require(jsonString.data(using: .utf8))
        let days = try #require(JSONSerialization.jsonObject(with: data) as? [Any])

        // Then
        #expect(days.isEmpty)
    }

    @Test("artist 특수문자가 포함돼도 유효한 JSON이어야 한다")
    func artist_특수문자가_포함돼도_유효한_JSON이어야_한다() throws {
        // Given
        let date = try #require(DateFormatterService.date(from: "2026-07-22", type: .dashDate))
        let month = CalendarMonth(
            dayList: [
                CalendarMonthDay(
                    date: date,
                    eventList: [
                        CalendarMonthEvent(
                            concertID: 42,
                            artist: "A\"B\\C\nD",
                            type: .ticketing
                        )
                    ]
                )
            ]
        )

        // When
        let jsonString = try #require(CalendarWebMonthPayloadMapper.jsonString(from: month))
        let data = try #require(jsonString.data(using: .utf8))
        let days = try #require(JSONSerialization.jsonObject(with: data) as? [[String: Any]])

        // Then
        let events = try #require(days[0]["events"] as? [[String: Any]])
        #expect(events[0]["id"] as? Int == 42)
        #expect(events[0]["artist"] as? String == "A\"B\\C\nD")
        #expect(events[0]["type"] as? String == "TICKETING")
    }
}
