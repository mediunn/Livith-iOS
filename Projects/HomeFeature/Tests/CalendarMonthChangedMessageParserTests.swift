//
//  CalendarMonthChangedMessageParserTests.swift
//  HomeFeatureTests
//
//  Created by 김진웅 on 7/24/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation
import Testing

@testable import HomeFeature

@Suite("CalendarMonthChangedMessageParser")
struct CalendarMonthChangedMessageParserTests {

    @Test("딕셔너리 body에서 year month를 파싱해야 한다")
    func 딕셔너리_body에서_year_month를_파싱해야_한다() {
        // Given
        let body: [String: Any] = ["year": 2026, "month": 8]

        // When
        let yearMonth = CalendarMonthChangedMessageParser.yearMonth(from: body)

        // Then
        #expect(yearMonth?.year == 2026)
        #expect(yearMonth?.month == 8)
    }

    @Test("JSON 문자열 body에서 year month를 파싱해야 한다")
    func JSON_문자열_body에서_year_month를_파싱해야_한다() {
        // Given
        let body = #"{"year":2026,"month":8}"#

        // When
        let yearMonth = CalendarMonthChangedMessageParser.yearMonth(from: body)

        // Then
        #expect(yearMonth?.year == 2026)
        #expect(yearMonth?.month == 8)
    }

    @Test("NSDictionary body에서 year month를 파싱해야 한다")
    func NSDictionary_body에서_year_month를_파싱해야_한다() {
        // Given
        let body = NSDictionary(dictionary: ["year": 2026, "month": 8])

        // When
        let yearMonth = CalendarMonthChangedMessageParser.yearMonth(from: body)

        // Then
        #expect(yearMonth?.year == 2026)
        #expect(yearMonth?.month == 8)
    }

    @Test("month 범위 밖이거나 필드가 없으면 nil을 반환해야 한다")
    func month_범위_밖이거나_필드가_없으면_nil을_반환해야_한다() {
        #expect(CalendarMonthChangedMessageParser.yearMonth(from: ["year": 2026, "month": 0]) == nil)
        #expect(CalendarMonthChangedMessageParser.yearMonth(from: ["year": 2026, "month": 13]) == nil)
        #expect(CalendarMonthChangedMessageParser.yearMonth(from: ["year": 2026]) == nil)
        #expect(CalendarMonthChangedMessageParser.yearMonth(from: ["month": 8]) == nil)
        #expect(CalendarMonthChangedMessageParser.yearMonth(from: 42) == nil)
    }
}
