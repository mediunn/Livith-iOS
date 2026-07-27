//
//  CalendarMapperTests.swift
//  CalendarDataTests
//
//  Created by 김진웅 on 7/23/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation
import Testing

import Domain
import LivithFoundation
import LivithNetworking
@testable import CalendarData

@Suite("캘린더 매퍼")
struct CalendarMapperTests {

    @Test("월별 응답의 유효한 이벤트를 Domain으로 변환해야 한다")
    func 월별_응답의_유효한_이벤트를_Domain으로_변환해야_한다() throws {
        // Given
        let sut = CalendarMapper()
        let json = """
        [
          {
            "date": "2026-04-02",
            "events": [
              {
                "id": 1678,
                "artist": "Matthew Ifield",
                "type": "TICKETING"
              }
            ]
          }
        ]
        """.data(using: .utf8)!
        let dto = try JSONDecoder().decode(DTO.Response.FetchCalendarMonth.self, from: json)

        // When
        let result = sut.toDomain(from: dto)

        // Then
        #expect(result.dayList.count == 1)
        let day = try #require(result.dayList.first)
        #expect(day.date == DateFormatterService.date(from: "2026-04-02", type: .dashDate))
        #expect(day.eventList.count == 1)
        #expect(day.eventList[0].concertID == 1678)
        #expect(day.eventList[0].artist == "Matthew Ifield")
        #expect(day.eventList[0].type == .ticketing)
    }

    @Test("월별 응답에서 알 수 없는 type 이벤트는 제외해야 한다")
    func 월별_응답에서_알_수_없는_type_이벤트는_제외해야_한다() throws {
        // Given
        let sut = CalendarMapper()
        let json = """
        [
          {
            "date": "2026-04-02",
            "events": [
              { "id": 1, "artist": "A", "type": "INVALID" },
              { "id": 2, "artist": "B", "type": "CONCERT" }
            ]
          }
        ]
        """.data(using: .utf8)!
        let dto = try JSONDecoder().decode(DTO.Response.FetchCalendarMonth.self, from: json)

        // When
        let result = sut.toDomain(from: dto)

        // Then
        #expect(result.dayList.count == 1)
        #expect(result.dayList[0].eventList.map(\.concertID) == [2])
        #expect(result.dayList[0].eventList[0].type == .concert)
    }

    @Test("월별 응답에서 date 파싱 실패 day는 제외해야 한다")
    func 월별_응답에서_date_파싱_실패_day는_제외해야_한다() throws {
        // Given
        let sut = CalendarMapper()
        let json = """
        [
          {
            "date": "not-a-date",
            "events": [
              { "id": 1, "artist": "A", "type": "TICKETING" }
            ]
          },
          {
            "date": "2026-04-03",
            "events": [
              { "id": 2, "artist": "B", "type": "TICKETING" }
            ]
          }
        ]
        """.data(using: .utf8)!
        let dto = try JSONDecoder().decode(DTO.Response.FetchCalendarMonth.self, from: json)

        // When
        let result = sut.toDomain(from: dto)

        // Then
        #expect(result.dayList.count == 1)
        #expect(result.dayList[0].eventList.map(\.concertID) == [2])
    }

    @Test("빈 월별 응답 배열은 빈 dayList로 변환해야 한다")
    func 빈_월별_응답_배열은_빈_dayList로_변환해야_한다() throws {
        // Given
        let sut = CalendarMapper()
        let json = "[]".data(using: .utf8)!
        let dto = try JSONDecoder().decode(DTO.Response.FetchCalendarMonth.self, from: json)

        // When
        let result = sut.toDomain(from: dto)

        // Then
        #expect(result.dayList.isEmpty)
    }

    @Test("날짜별 응답의 time·detail을 Domain으로 변환해야 한다")
    func 날짜별_응답의_time_detail을_Domain으로_변환해야_한다() throws {
        // Given
        let sut = CalendarMapper()
        let json = """
        {
          "date": "2026-05-08",
          "events": [
            {
              "id": 1903,
              "title": "라이빗 공연2",
              "type": "GENERAL_TICKETING",
              "status": "COMPLETED",
              "time": "14:00",
              "detail": "NOL 티켓"
            },
            {
              "id": 1672,
              "title": "WIM",
              "type": "CONCERT",
              "status": "UPCOMING",
              "time": null,
              "detail": "예스24 원더로크홀"
            }
          ]
        }
        """.data(using: .utf8)!
        let dto = try JSONDecoder().decode(DTO.Response.FetchCalendarDayEvents.self, from: json)

        // When
        let result = try #require(sut.toDomain(from: dto))

        // Then
        #expect(result.date == DateFormatterService.date(from: "2026-05-08", type: .dashDate))
        #expect(result.eventList.count == 2)
        #expect(result.eventList[0].time == CalendarEventTime(hour: 14, minute: 0))
        #expect(result.eventList[0].detail == .ticketOffice("NOL 티켓"))
        #expect(result.eventList[1].time == nil)
        #expect(result.eventList[1].detail == .venue("예스24 원더로크홀"))
    }

    @Test("날짜별 응답에서 같은 concertID·다른 time 행은 모두 유지되어야 한다")
    func 날짜별_응답에서_같은_concertID_다른_time_행은_모두_유지되어야_한다() throws {
        // Given
        let sut = CalendarMapper()
        let json = """
        {
          "date": "2026-07-26",
          "events": [
            {
              "id": 1978,
              "title": "스미다 아이코 & 모치즈키 루카 조인트 콘서트 & OVAL SISTEM in SEOUL",
              "type": "CONCERT",
              "status": "UPCOMING",
              "time": "12:20",
              "detail": "퍼플노이즈 라이브홀"
            },
            {
              "id": 1978,
              "title": "스미다 아이코 & 모치즈키 루카 조인트 콘서트 & OVAL SISTEM in SEOUL",
              "type": "CONCERT",
              "status": "UPCOMING",
              "time": "17:00",
              "detail": "퍼플노이즈 라이브홀"
            },
            {
              "id": 1683,
              "title": "CUTIE STREET SUMMER Live",
              "type": "CONCERT",
              "status": "UPCOMING",
              "time": "18:00",
              "detail": "세종대학교 대양홀"
            }
          ]
        }
        """.data(using: .utf8)!
        let dto = try JSONDecoder().decode(DTO.Response.FetchCalendarDayEvents.self, from: json)

        // When
        let result = try #require(sut.toDomain(from: dto))

        // Then
        #expect(result.eventList.count == 3)
        #expect(result.eventList.map(\.concertID) == [1978, 1978, 1683])
        #expect(result.eventList.map(\.time) == [
            CalendarEventTime(hour: 12, minute: 20),
            CalendarEventTime(hour: 17, minute: 0),
            CalendarEventTime(hour: 18, minute: 0)
        ])
        #expect(Set(result.eventList.map(\.id)).count == 3)
    }

    @Test("날짜별 응답에서 잘못된 time은 nil로 두고 이벤트는 유지해야 한다")
    func 날짜별_응답에서_잘못된_time은_nil로_두고_이벤트는_유지해야_한다() throws {
        // Given
        let sut = CalendarMapper()
        let json = """
        {
          "date": "2026-05-08",
          "events": [
            {
              "id": 1,
              "title": "A",
              "type": "CONCERT",
              "status": "UPCOMING",
              "time": "25:00",
              "detail": null
            }
          ]
        }
        """.data(using: .utf8)!
        let dto = try JSONDecoder().decode(DTO.Response.FetchCalendarDayEvents.self, from: json)

        // When
        let result = try #require(sut.toDomain(from: dto))

        // Then
        #expect(result.eventList.count == 1)
        #expect(result.eventList[0].time == nil)
    }

    @Test("날짜별 응답에서 알 수 없는 status는 이벤트를 제외해야 한다")
    func 날짜별_응답에서_알_수_없는_status는_이벤트를_제외해야_한다() throws {
        // Given
        let sut = CalendarMapper()
        let json = """
        {
          "date": "2026-05-08",
          "events": [
            {
              "id": 1,
              "title": "A",
              "type": "CONCERT",
              "status": "WEIRD",
              "time": "20:00",
              "detail": null
            },
            {
              "id": 2,
              "title": "B",
              "type": "CONCERT",
              "status": "CANCELLED",
              "time": null,
              "detail": ""
            }
          ]
        }
        """.data(using: .utf8)!
        let dto = try JSONDecoder().decode(DTO.Response.FetchCalendarDayEvents.self, from: json)

        // When
        let result = try #require(sut.toDomain(from: dto))

        // Then
        #expect(result.eventList.map(\.concertID) == [2])
        #expect(result.eventList[0].status == .cancelled)
        #expect(result.eventList[0].detail == nil)
    }
}
