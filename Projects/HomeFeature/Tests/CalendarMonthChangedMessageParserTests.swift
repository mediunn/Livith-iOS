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

    @Test("딕셔너리 body에서 startDate endDate를 파싱해야 한다")
    func 딕셔너리_body에서_startDate_endDate를_파싱해야_한다() {
        // Given
        let body: [String: Any] = [
            "startDate": "2026-01-01",
            "endDate": "2026-01-31"
        ]

        // When
        let dateRange = CalendarMonthChangedMessageParser.dateRange(from: body)

        // Then
        #expect(dateRange?.startDate == "2026-01-01")
        #expect(dateRange?.endDate == "2026-01-31")
    }

    @Test("JSON 문자열 body에서 startDate endDate를 파싱해야 한다")
    func JSON_문자열_body에서_startDate_endDate를_파싱해야_한다() {
        // Given
        let body = #"{"startDate":"2026-08-01","endDate":"2026-08-31"}"#

        // When
        let dateRange = CalendarMonthChangedMessageParser.dateRange(from: body)

        // Then
        #expect(dateRange?.startDate == "2026-08-01")
        #expect(dateRange?.endDate == "2026-08-31")
    }

    @Test("NSDictionary body에서 startDate endDate를 파싱해야 한다")
    func NSDictionary_body에서_startDate_endDate를_파싱해야_한다() {
        // Given
        let body = NSDictionary(dictionary: [
            "startDate": "2026-08-01",
            "endDate": "2026-08-31"
        ])

        // When
        let dateRange = CalendarMonthChangedMessageParser.dateRange(from: body)

        // Then
        #expect(dateRange?.startDate == "2026-08-01")
        #expect(dateRange?.endDate == "2026-08-31")
    }

    @Test("필드가 없거나 날짜 형식이 잘못되면 nil을 반환해야 한다")
    func 필드가_없거나_날짜_형식이_잘못되면_nil을_반환해야_한다() {
        #expect(CalendarMonthChangedMessageParser.dateRange(from: ["startDate": "2026-01-01"]) == nil)
        #expect(CalendarMonthChangedMessageParser.dateRange(from: ["endDate": "2026-01-31"]) == nil)
        #expect(CalendarMonthChangedMessageParser.dateRange(from: [
            "startDate": "2026/01/01",
            "endDate": "2026-01-31"
        ]) == nil)
        #expect(CalendarMonthChangedMessageParser.dateRange(from: [
            "startDate": "2026-01-01",
            "endDate": "invalid"
        ]) == nil)
        #expect(CalendarMonthChangedMessageParser.dateRange(from: [
            "year": 2026,
            "month": 8
        ]) == nil)
        #expect(CalendarMonthChangedMessageParser.dateRange(from: 42) == nil)
    }
}
