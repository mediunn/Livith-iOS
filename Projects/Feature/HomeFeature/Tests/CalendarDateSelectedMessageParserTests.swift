//
//  CalendarDateSelectedMessageParserTests.swift
//  HomeFeatureTests
//
//  Created by 김진웅 on 7/24/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation
import Testing

import LivithFoundation

@testable import HomeFeature

@Suite("CalendarDateSelectedMessageParser")
struct CalendarDateSelectedMessageParserTests {

    @Test("딕셔너리 body에서 date를 파싱해야 한다")
    func 딕셔너리_body에서_date를_파싱해야_한다() throws {
        // Given
        let body: [String: Any] = ["date": "2026-07-22"]

        // When
        let date = CalendarDateSelectedMessageParser.date(from: body)

        // Then
        let expected = try #require(DateFormatterService.date(from: "2026-07-22", type: .dashDate))
        #expect(date == expected)
    }

    @Test("JSON 문자열 body에서 date를 파싱해야 한다")
    func JSON_문자열_body에서_date를_파싱해야_한다() throws {
        // Given
        let body = #"{"date":"2026-07-22"}"#

        // When
        let date = CalendarDateSelectedMessageParser.date(from: body)

        // Then
        let expected = try #require(DateFormatterService.date(from: "2026-07-22", type: .dashDate))
        #expect(date == expected)
    }

    @Test("yyyy-MM-dd 문자열 body를 파싱해야 한다")
    func yyyy_MM_dd_문자열_body를_파싱해야_한다() throws {
        // Given
        let body = "2026-07-22"

        // When
        let date = CalendarDateSelectedMessageParser.date(from: body)

        // Then
        let expected = try #require(DateFormatterService.date(from: "2026-07-22", type: .dashDate))
        #expect(date == expected)
    }

    @Test("NSDictionary body에서 date를 파싱해야 한다")
    func NSDictionary_body에서_date를_파싱해야_한다() throws {
        // Given
        let body = NSDictionary(dictionary: ["date": "2026-07-22"])

        // When
        let date = CalendarDateSelectedMessageParser.date(from: body)

        // Then
        let expected = try #require(DateFormatterService.date(from: "2026-07-22", type: .dashDate))
        #expect(date == expected)
    }

    @Test("잘못된 body는 nil을 반환해야 한다")
    func 잘못된_body는_nil을_반환해야_한다() {
        #expect(CalendarDateSelectedMessageParser.date(from: ["foo": "bar"]) == nil)
        #expect(CalendarDateSelectedMessageParser.date(from: 42) == nil)
        #expect(CalendarDateSelectedMessageParser.date(from: "not-a-date") == nil)
    }
}
