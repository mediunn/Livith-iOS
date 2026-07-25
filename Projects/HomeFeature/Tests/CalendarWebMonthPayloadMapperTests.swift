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

    @Test("월 데이터를 웹 계약 JSON으로 직렬화해야 한다")
    func 월_데이터를_웹_계약_JSON으로_직렬화해야_한다() throws {
        // Given
        let date = try #require(DateFormatterService.date(from: "2026-07-22", type: .dashDate))
        let month = CalendarMonth(
            year: 2026,
            month: 7,
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
        let json = try #require(JSONSerialization.jsonObject(with: data) as? [String: Any])

        // Then
        #expect(json["year"] as? Int == 2026)
        #expect(json["month"] as? Int == 7)
        let days = try #require(json["days"] as? [[String: Any]])
        #expect(days.count == 1)
        #expect(days[0]["date"] as? String == "2026-07-22")
        let events = try #require(days[0]["events"] as? [[String: Any]])
        #expect(events.count == 1)
        #expect(events[0]["id"] as? Int == 1)
        #expect(events[0]["artist"] as? String == "Coldplay")
        #expect(events[0]["type"] as? String == "CONCERT")
    }

    @Test("빈 dayList여도 year month와 빈 days를 직렬화해야 한다")
    func 빈_dayList여도_year_month와_빈_days를_직렬화해야_한다() throws {
        // Given
        let month = CalendarMonth(year: 2026, month: 7, dayList: [])

        // When
        let jsonString = try #require(CalendarWebMonthPayloadMapper.jsonString(from: month))
        let data = try #require(jsonString.data(using: .utf8))
        let json = try #require(JSONSerialization.jsonObject(with: data) as? [String: Any])

        // Then
        #expect(json["year"] as? Int == 2026)
        #expect(json["month"] as? Int == 7)
        let days = try #require(json["days"] as? [Any])
        #expect(days.isEmpty)
    }

    @Test("artist 특수문자가 포함돼도 유효한 JSON이어야 한다")
    func artist_특수문자가_포함돼도_유효한_JSON이어야_한다() throws {
        // Given
        let date = try #require(DateFormatterService.date(from: "2026-07-22", type: .dashDate))
        let month = CalendarMonth(
            year: 2026,
            month: 7,
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
        let json = try #require(JSONSerialization.jsonObject(with: data) as? [String: Any])

        // Then
        let days = try #require(json["days"] as? [[String: Any]])
        let events = try #require(days[0]["events"] as? [[String: Any]])
        #expect(events[0]["id"] as? Int == 42)
        #expect(events[0]["artist"] as? String == "A\"B\\C\nD")
        #expect(events[0]["type"] as? String == "TICKETING")
    }
}
