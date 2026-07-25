//
//  CalendarDomainModelTests.swift
//  DomainTests
//
//  Created by 김진웅 on 7/23/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation
import Testing

@testable import Domain

@Suite("캘린더 Domain 모델")
struct CalendarDomainModelTests {

    @Test("CalendarEventID는 같은 concertID라도 type이 다르면 달라야 한다")
    func calendarEventID는_같은_concertID라도_type이_다르면_달라야_한다() {
        // Given
        let ticketing = CalendarEventID(concertID: 1903, type: CalendarDayEventType.generalTicketing)
        let concert = CalendarEventID(concertID: 1903, type: CalendarDayEventType.concert)

        // Then
        #expect(ticketing != concert)
    }

    @Test("CalendarEventDetail는 티켓오피스와 공연장소를 구분해야 한다")
    func calendarEventDetail는_티켓오피스와_공연장소를_구분해야_한다() {
        // Given
        let ticketOffice = CalendarEventDetail.ticketOffice("NOL 티켓")
        let venue = CalendarEventDetail.venue("예스24 원더로크홀")

        // Then
        #expect(ticketOffice.text == "NOL 티켓")
        #expect(venue.text == "예스24 원더로크홀")
        #expect(ticketOffice.isTicketOffice)
        #expect(venue.isVenue)
        #expect(ticketOffice != venue)
    }

    @Test("CalendarEventDetail는 일정 type에 맞춰 ticketOffice 또는 venue를 만들어야 한다")
    func calendarEventDetail는_일정_type에_맞춰_ticketOffice_또는_venue를_만들어야_한다() {
        // When
        let ticketOffice = CalendarEventDetail.make(text: "NOL 티켓", aligningWith: .generalTicketing)
        let venue = CalendarEventDetail.make(text: "올림픽공원", aligningWith: .concert)

        // Then
        #expect(ticketOffice == .ticketOffice("NOL 티켓"))
        #expect(venue == .venue("올림픽공원"))
    }

    @Test("CalendarEventTime은 시·분 순으로 비교해야 한다")
    func calendarEventTime은_시_분_순으로_비교해야_한다() {
        // Given
        let earlier = CalendarEventTime(hour: 14, minute: 0)
        let laterSameHour = CalendarEventTime(hour: 14, minute: 30)
        let laterHour = CalendarEventTime(hour: 20, minute: 0)

        // Then
        #expect(earlier < laterSameHour)
        #expect(laterSameHour < laterHour)
    }

    @Test("CalendarDayEvent의 id는 concertID와 type으로 합성되어야 한다")
    func calendarDayEvent의_id는_concertID와_type으로_합성되어야_한다() {
        // Given
        let event = CalendarDayEvent(
            concertID: 1903,
            title: "라이빗 공연2",
            type: .generalTicketing,
            status: .completed,
            time: CalendarEventTime(hour: 14, minute: 0),
            detail: .ticketOffice("NOL 티켓")
        )

        // Then
        #expect(event.id == CalendarEventID(concertID: 1903, type: .generalTicketing))
        #expect(event.concertID == 1903)
        #expect(event.title == "라이빗 공연2")
        #expect(event.status.isCancelled == false)
    }

    @Test("CalendarDayEventStatus cancelled는 isCancelled가 true여야 한다")
    func calendarDayEventStatus_cancelled는_isCancelled가_true여야_한다() {
        #expect(CalendarDayEventStatus.cancelled.isCancelled)
        #expect(CalendarDayEventStatus.upcoming.isCancelled == false)
    }

    @Test("CalendarMonthDay의 id는 date와 같아야 한다")
    func calendarMonthDay의_id는_date와_같아야_한다() {
        // Given
        let date = Date(timeIntervalSince1970: 1_775_001_600)
        let day = CalendarMonthDay(
            date: date,
            eventList: [
                CalendarMonthEvent(concertID: 1662, artist: "Livith", type: .ticketing)
            ]
        )

        // Then
        #expect(day.id == date)
        #expect(day.eventList.count == 1)
        #expect(day.eventList[0].id == CalendarEventID(concertID: 1662, type: .ticketing))
    }

    @Test("CalendarMonth는 sparse dayList를 유지해야 한다")
    func calendarMonth는_sparse_dayList를_유지해야_한다() {
        // Given
        let date = Date(timeIntervalSince1970: 1_775_001_600)
        let month = CalendarMonth(
            year: 2026,
            month: 4,
            dayList: [
                CalendarMonthDay(date: date, eventList: [])
            ]
        )

        // Then
        #expect(month.year == 2026)
        #expect(month.month == 4)
        #expect(month.dayList.count == 1)
    }
}
