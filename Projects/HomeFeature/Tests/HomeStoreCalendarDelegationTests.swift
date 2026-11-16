//
//  HomeStoreCalendarDelegationTests.swift
//  HomeFeatureTests
//
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

import Testing

import DIContainer
import Domain

@testable import HomeFeature

@MainActor
@Suite("홈 스토어 캘린더 위임")
struct HomeStoreCalendarDelegationTests {

    let container: MockDIContainer

    init() {
        self.container = MockDIContainer()
        self.container.registerDependencies()
    }

    @Test("calendar Intent는 HomeState.calendar만 갱신해야 한다")
    func calendar_Intent는_HomeState_calendar만_갱신해야_한다() async throws {
        // Given
        let month = CalendarMonth(dayList: [])
        container.calendarRepository.fetchMonthResultQueue = [.success(month)]
        let sut = HomeStore()
        let previousTab = sut.state.selectedHomeTab

        // When
        sut.send(.calendar(.monthChanged(startDate: "2026-08-01", endDate: "2026-08-31")))
        try await Task.sleep(nanoseconds: 100_000_000)

        // Then
        #expect(sut.state.selectedHomeTab == previousTab)
        #expect(sut.state.calendar.rangeStartDate == "2026-08-01")
        #expect(sut.state.calendar.calendarMonth == month)
    }

    @Test("pullToRefresh wait는 월별 fetch 완료까지 대기해야 한다")
    func pullToRefresh_wait는_월별_fetch_완료까지_대기해야_한다() async throws {
        // Given
        container.calendarRepository.fetchMonthResultQueue = [
            .success(CalendarMonth(dayList: [])),
            .success(CalendarMonth(dayList: []))
        ]
        let sut = HomeStore()
        sut.send(.calendar(.monthChanged(startDate: "2026-07-01", endDate: "2026-07-31")))
        try await Task.sleep(nanoseconds: 100_000_000)

        // When
        await sut.send(.calendar(.pullToRefresh)).wait()

        // Then
        #expect(container.calendarRepository.fetchMonthCallCount == 2)
        #expect(!sut.state.calendar.isInitialLoading)
    }

    @Test("range 없이 pullToRefresh하면 초기 로딩을 유지하고 조회하지 않아야 한다")
    func pullToRefresh_없이_range_초기로딩_유지해야_한다() {
        // Given: 월 범위가 없어 onAppear가 중앙 로딩을 켠 상태
        let sut = HomeStore()
        sut.send(.calendar(.onAppear))
        #expect(sut.state.calendar.isInitialLoading)

        // When
        sut.send(.calendar(.pullToRefresh))

        // Then
        #expect(sut.state.calendar.isInitialLoading)
        #expect(container.calendarRepository.fetchMonthCallCount == 0)
    }
}
