//
//  CalendarWebScriptMessageBodyParserTests.swift
//  HomeFeatureTests
//
//  Created by 김진웅 on 7/25/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation
import Testing

@testable import HomeFeature

@Suite("CalendarWebScriptMessageBodyParser")
struct CalendarWebScriptMessageBodyParserTests {

    @Test("딕셔너리 body를 그대로 반환해야 한다")
    func 딕셔너리_body를_그대로_반환해야_한다() {
        // Given
        let body: [String: Any] = ["date": "2026-07-22", "year": 2026]

        // When
        let dictionary = CalendarWebScriptMessageBodyParser.dictionary(from: body)

        // Then
        #expect(dictionary?["date"] as? String == "2026-07-22")
        #expect(dictionary?["year"] as? Int == 2026)
    }

    @Test("NSDictionary body를 dictionary로 변환해야 한다")
    func NSDictionary_body를_dictionary로_변환해야_한다() {
        // Given
        let body = NSDictionary(dictionary: ["month": 8, "year": 2026])

        // When
        let dictionary = CalendarWebScriptMessageBodyParser.dictionary(from: body)

        // Then
        #expect(dictionary?["month"] as? Int == 8)
        #expect(dictionary?["year"] as? Int == 2026)
    }

    @Test("JSON 문자열 body를 dictionary로 변환해야 한다")
    func JSON_문자열_body를_dictionary로_변환해야_한다() {
        // Given
        let body = #"{"year":2026,"month":8}"#

        // When
        let dictionary = CalendarWebScriptMessageBodyParser.dictionary(from: body)

        // Then
        #expect(dictionary?["year"] as? Int == 2026)
        #expect(dictionary?["month"] as? Int == 8)
    }

    @Test("JSON이 아닌 문자열 body는 nil을 반환해야 한다")
    func JSON이_아닌_문자열_body는_nil을_반환해야_한다() {
        #expect(CalendarWebScriptMessageBodyParser.dictionary(from: "2026-07-22") == nil)
        #expect(CalendarWebScriptMessageBodyParser.dictionary(from: "not-json") == nil)
    }

    @Test("지원하지 않는 body는 nil을 반환해야 한다")
    func 지원하지_않는_body는_nil을_반환해야_한다() {
        #expect(CalendarWebScriptMessageBodyParser.dictionary(from: 42) == nil)
        #expect(CalendarWebScriptMessageBodyParser.dictionary(from: ["a", "b"]) == nil)
    }

    @Test("Int 값을 그대로 반환해야 한다")
    func Int_값을_그대로_반환해야_한다() {
        #expect(CalendarWebScriptMessageBodyParser.intValue(8) == 8)
    }

    @Test("NSNumber 값을 Int로 변환해야 한다")
    func NSNumber_값을_Int로_변환해야_한다() {
        #expect(CalendarWebScriptMessageBodyParser.intValue(NSNumber(value: 2026)) == 2026)
    }

    @Test("Int가 아닌 값은 nil을 반환해야 한다")
    func Int가_아닌_값은_nil을_반환해야_한다() {
        #expect(CalendarWebScriptMessageBodyParser.intValue(nil) == nil)
        #expect(CalendarWebScriptMessageBodyParser.intValue("8") == nil)
    }
}
