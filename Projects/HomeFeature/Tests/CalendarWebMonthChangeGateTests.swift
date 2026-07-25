//
//  CalendarWebMonthChangeGateTests.swift
//  HomeFeatureTests
//
//  Created by 김진웅 on 7/25/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Testing

@testable import HomeFeature

@Suite("CalendarWebMonthChangeGate")
struct CalendarWebMonthChangeGateTests {

    @Test("초기에는 monthChanged를 받지 않아야 한다")
    func 초기에는_monthChanged를_받지_않아야_한다() {
        // Given
        let sut = CalendarWebMonthChangeGate()

        // Then
        #expect(!sut.shouldAcceptMonthChanged)
    }

    @Test("inject 성공 후에는 monthChanged를 받아야 한다")
    func inject_성공_후에는_monthChanged를_받아야_한다() {
        // Given
        var sut = CalendarWebMonthChangeGate()

        // When
        sut.markInjectSucceeded()

        // Then
        #expect(sut.shouldAcceptMonthChanged)
    }

    @Test("reset 후에는 다시 monthChanged를 받지 않아야 한다")
    func reset_후에는_다시_monthChanged를_받지_않아야_한다() {
        // Given
        var sut = CalendarWebMonthChangeGate()
        sut.markInjectSucceeded()

        // When
        sut.reset()

        // Then
        #expect(!sut.shouldAcceptMonthChanged)
    }
}
