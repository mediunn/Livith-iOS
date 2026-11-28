//
//  CalendarHomeStoreTests.swift
//  HomeFeatureTests
//
//  Created by 김진웅 on 7/19/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

import Testing

import DIContainer
import Domain
import LivithFoundation

@testable import HomeFeature

@MainActor
@Suite("캘린더 홈")
struct CalendarHomeStoreTests {

    let container: MockDIContainer

    init() {
        self.container = MockDIContainer()
        self.container.registerDependencies()
    }

    @Test("초기 상태에서 예매일·공연일은 on이고 공연 범위는 전체 공연이어야 한다")
    func 초기_상태에서_예매일_공연일은_on이고_공연_범위는_전체_공연이어야_한다() {
        // Given
        let sut = HomeStore()

        // Then
        #expect(sut.state.calendar.isTicketingDateSelected)
        #expect(sut.state.calendar.isPerformanceDateSelected)
        #expect(sut.state.calendar.concertScope == .all)
        #expect(sut.state.calendar.selectionBlockedToastMessage.isEmpty)
        #expect(!sut.state.calendar.isLoadFailed)
        #expect(!sut.state.calendar.isInitialLoading)
        #expect(sut.state.calendar.rangeStartDate == nil)
    }

    @Test("예매일 칩 탭 시 예매일 선택 상태가 토글되어야 한다")
    func 예매일_칩_탭_시_예매일_선택_상태가_토글되어야_한다() async throws {
        // Given
        let sut = HomeStore()
        try await seedJulyRange(sut)
        container.calendarRepository.fetchMonthResultQueue = [.success(makeMonth())]

        // When
        sut.send(.calendar(.ticketingDateTapped))
        try await waitForAsyncTask()

        // Then
        #expect(!sut.state.calendar.isTicketingDateSelected)
        #expect(sut.state.calendar.isPerformanceDateSelected)
        #expect(sut.state.calendar.selectionBlockedToastMessage.isEmpty)
        #expect(container.calendarRepository.fetchMonthCallCount == 2)
    }

    @Test("공연일 칩 탭 시 공연일 선택 상태가 토글되어야 한다")
    func 공연일_칩_탭_시_공연일_선택_상태가_토글되어야_한다() async throws {
        // Given
        let sut = HomeStore()
        try await seedJulyRange(sut)
        container.calendarRepository.fetchMonthResultQueue = [.success(makeMonth())]

        // When
        sut.send(.calendar(.performanceDateTapped))
        try await waitForAsyncTask()

        // Then
        #expect(sut.state.calendar.isTicketingDateSelected)
        #expect(!sut.state.calendar.isPerformanceDateSelected)
        #expect(sut.state.calendar.selectionBlockedToastMessage.isEmpty)
        #expect(container.calendarRepository.fetchMonthCallCount == 2)
    }

    @Test("마지막 on인 예매일 칩 off 시도 시 상태는 유지되고 선택 불가 토스트가 설정되어야 한다")
    func 마지막_on인_예매일_칩_off_시도_시_상태는_유지되고_선택_불가_토스트가_설정되어야_한다() {
        // Given
        let sut = HomeStore()
        sut.send(.calendar(.performanceDateTapped))

        // When
        sut.send(.calendar(.ticketingDateTapped))

        // Then
        #expect(sut.state.calendar.isTicketingDateSelected)
        #expect(!sut.state.calendar.isPerformanceDateSelected)
        #expect(sut.state.calendar.selectionBlockedToastMessage == CalendarHomeConstants.selectionBlockedToastMessage)
    }

    @Test("마지막 on인 공연일 칩 off 시도 시 상태는 유지되고 선택 불가 토스트가 설정되어야 한다")
    func 마지막_on인_공연일_칩_off_시도_시_상태는_유지되고_선택_불가_토스트가_설정되어야_한다() {
        // Given
        let sut = HomeStore()
        sut.send(.calendar(.ticketingDateTapped))

        // When
        sut.send(.calendar(.performanceDateTapped))

        // Then
        #expect(!sut.state.calendar.isTicketingDateSelected)
        #expect(sut.state.calendar.isPerformanceDateSelected)
        #expect(sut.state.calendar.selectionBlockedToastMessage == CalendarHomeConstants.selectionBlockedToastMessage)
    }

    @Test("전체 공연 칩 탭 시 공연 범위가 전체 공연으로 전환되어야 한다")
    func 전체_공연_칩_탭_시_공연_범위가_전체_공연으로_전환되어야_한다() async throws {
        // Given
        let sut = HomeStore()
        try await seedJulyRange(sut)
        container.calendarRepository.fetchMonthResultQueue = [
            .success(makeMonth()),
            .success(makeMonth())
        ]
        sut.send(.calendar(.myConcertsTapped))
        try await waitForAsyncTask()

        // When
        sut.send(.calendar(.allConcertsTapped))
        try await waitForAsyncTask()

        // Then
        #expect(sut.state.calendar.concertScope == .all)
    }

    @Test("내 공연 칩 탭 시 공연 범위가 내 공연으로 전환되어야 한다")
    func 내_공연_칩_탭_시_공연_범위가_내_공연으로_전환되어야_한다() async throws {
        // Given
        let sut = HomeStore()
        try await seedJulyRange(sut)
        container.calendarRepository.fetchMonthResultQueue = [.success(makeMonth())]

        // When
        sut.send(.calendar(.myConcertsTapped))
        try await waitForAsyncTask()

        // Then
        #expect(sut.state.calendar.concertScope == .my)
        #expect(container.calendarRepository.fetchMonthCallCount == 2)
        #expect(container.calendarRepository.fetchMonthParameterList.last?.concertType == .interest)
    }

    @Test("선택 불가 토스트 dismiss 시 메시지가 클리어되어야 한다")
    func 선택_불가_토스트_dismiss_시_메시지가_클리어되어야_한다() {
        // Given
        let sut = HomeStore()
        sut.send(.calendar(.performanceDateTapped))
        sut.send(.calendar(.ticketingDateTapped))

        // When
        sut.send(.calendar(.onSelectionBlockedToastDisappear))

        // Then
        #expect(sut.state.calendar.selectionBlockedToastMessage.isEmpty)
        #expect(sut.state.calendar.selectionBlockedToastTrigger == 1)
    }

    @Test("연속 선택 불가 시도 시 토스트 트리거가 증가해야 한다")
    func 연속_선택_불가_시도_시_토스트_트리거가_증가해야_한다() {
        // Given
        let sut = HomeStore()
        sut.send(.calendar(.performanceDateTapped))
        sut.send(.calendar(.ticketingDateTapped))
        let firstTrigger = sut.state.calendar.selectionBlockedToastTrigger

        // When
        sut.send(.calendar(.onSelectionBlockedToastDisappear))
        sut.send(.calendar(.ticketingDateTapped))

        // Then
        #expect(sut.state.calendar.selectionBlockedToastTrigger == firstTrigger + 1)
    }

    @Test("onAppear는 기간이 없으면 fetch하지 않고 로딩만 켜야 한다")
    func onAppear는_기간이_없으면_fetch하지_않고_로딩만_켜야_한다() {
        // Given
        let sut = HomeStore()

        // When
        sut.send(.calendar(.onAppear))

        // Then
        #expect(sut.state.calendar.isInitialLoading)
        #expect(container.calendarRepository.fetchMonthCallCount == 0)
    }

    @Test("monthChanged 성공 시 기간과 calendarMonth가 갱신되어야 한다")
    func monthChanged_성공_시_기간과_calendarMonth가_갱신되어야_한다() async throws {
        // Given
        let month = CalendarMonth(dayList: [])
        container.calendarRepository.fetchMonthResultQueue = [.success(month)]
        let sut = HomeStore()

        // When
        sut.send(.calendar(.monthChanged(startDate: "2026-08-01", endDate: "2026-08-31")))
        try await waitForAsyncTask()

        // Then
        #expect(sut.state.calendar.rangeStartDate == "2026-08-01")
        #expect(sut.state.calendar.rangeEndDate == "2026-08-31")
        #expect(sut.state.calendar.calendarMonth == month)
        #expect(!sut.state.calendar.isLoadFailed)
        #expect(container.calendarRepository.fetchMonthParameterList.last?.startDate == "2026-08-01")
        #expect(container.calendarRepository.fetchMonthParameterList.last?.endDate == "2026-08-31")
    }

    @Test("monthChanged 실패 시 isLoadFailed가 true여야 한다")
    func monthChanged_실패_시_isLoadFailed가_true여야_한다() async throws {
        // Given
        container.calendarRepository.fetchMonthResultQueue = [.failure(.serverError)]
        let sut = HomeStore()

        // When
        sut.send(.calendar(.monthChanged(startDate: "2026-08-01", endDate: "2026-08-31")))
        try await waitForAsyncTask()

        // Then
        #expect(sut.state.calendar.isLoadFailed)
        #expect(sut.state.calendar.rangeStartDate == "2026-08-01")
        #expect(sut.state.calendar.rangeEndDate == "2026-08-31")
    }

    @Test("로드된 뒤 onAppear는 초기 로딩 없이 같은 기간을 soft refresh해야 한다")
    func 로드된_뒤_onAppear는_초기_로딩_없이_같은_기간을_soft_refresh해야_한다() async throws {
        // Given
        let augustMonth = CalendarMonth(dayList: [])
        let refreshedAugust = CalendarMonth(
            dayList: [
                CalendarMonthDay(
                    date: makeDate(),
                    eventList: [
                        CalendarMonthEvent(concertID: 1, artist: "A", type: .concert)
                    ]
                )
            ]
        )
        container.calendarRepository.fetchMonthResultQueue = [
            .success(augustMonth),
            .success(refreshedAugust)
        ]
        let sut = HomeStore()
        sut.send(.calendar(.monthChanged(startDate: "2026-08-01", endDate: "2026-08-31")))
        try await waitForAsyncTask()

        // When
        sut.send(.calendar(.onAppear))

        // Then
        #expect(!sut.state.calendar.isInitialLoading)
        try await waitForAsyncTask()
        #expect(container.calendarRepository.fetchMonthCallCount == 2)
        #expect(sut.state.calendar.rangeStartDate == "2026-08-01")
        #expect(sut.state.calendar.calendarMonth == refreshedAugust)
        #expect(container.calendarRepository.fetchMonthParameterList.last?.startDate == "2026-08-01")
    }

    @Test("로드 실패 후 onAppear는 초기 로딩과 함께 같은 기간을 다시 조회해야 한다")
    func 로드_실패_후_onAppear는_초기_로딩과_함께_같은_기간을_다시_조회해야_한다() async throws {
        // Given
        container.calendarRepository.fetchMonthResultQueue = [
            .failure(.serverError),
            .success(makeMonth())
        ]
        let sut = HomeStore()
        sut.send(.calendar(.monthChanged(startDate: "2026-07-01", endDate: "2026-07-31")))
        try await waitForAsyncTask()

        // When
        sut.send(.calendar(.onAppear))

        // Then
        #expect(sut.state.calendar.isInitialLoading)
        try await waitForAsyncTask()
        #expect(sut.state.calendar.calendarMonth == makeMonth())
        #expect(!sut.state.calendar.isInitialLoading)
        #expect(!sut.state.calendar.isLoadFailed)
    }

    @Test("pullToRefresh는 로드 실패 상태에서도 중앙 로딩을 켜지 않아야 한다")
    func pullToRefresh는_로드_실패_상태에서도_중앙_로딩을_켜지_않아야_한다() async throws {
        // Given
        container.calendarRepository.fetchMonthResultQueue = [
            .failure(.serverError),
            .success(makeMonth())
        ]
        let sut = HomeStore()
        sut.send(.calendar(.monthChanged(startDate: "2026-07-01", endDate: "2026-07-31")))
        try await waitForAsyncTask()
        #expect(sut.state.calendar.isLoadFailed)

        container.calendarRepository.fetchMonthDelayNanoseconds = 100_000_000

        // When
        let refreshTask = Task { await sut.send(.calendar(.pullToRefresh)).wait() }
        try await Task.sleep(nanoseconds: 30_000_000)

        // Then
        #expect(!sut.state.calendar.isInitialLoading)
        #expect(sut.state.calendar.isLoadFailed)
        await refreshTask.value
        #expect(sut.state.calendar.calendarMonth == makeMonth())
        #expect(!sut.state.calendar.isInitialLoading)
        #expect(!sut.state.calendar.isLoadFailed)
    }

    @Test("pullToRefresh는 기간이 없어도 중앙 로딩을 켜지 않아야 한다")
    func pullToRefresh는_기간이_없어도_중앙_로딩을_켜지_않아야_한다() async {
        // Given
        let sut = HomeStore()

        // When
        await sut.send(.calendar(.pullToRefresh)).wait()

        // Then
        #expect(!sut.state.calendar.isInitialLoading)
        #expect(container.calendarRepository.fetchMonthCallCount == 0)
    }

    @Test("새로고침 시 필터 선택 상태는 유지되어야 한다")
    func 새로고침_시_필터_선택_상태는_유지되어야_한다() async throws {
        // Given
        let sut = HomeStore()
        try await seedJulyRange(sut)
        container.calendarRepository.fetchMonthResultQueue = [
            .success(makeMonth()),
            .success(makeMonth()),
            .success(makeMonth())
        ]
        sut.send(.calendar(.performanceDateTapped))
        try await waitForAsyncTask()
        sut.send(.calendar(.myConcertsTapped))
        try await waitForAsyncTask()

        // When
        await sut.send(.calendar(.pullToRefresh)).wait()

        // Then
        #expect(sut.state.calendar.isTicketingDateSelected)
        #expect(!sut.state.calendar.isPerformanceDateSelected)
        #expect(sut.state.calendar.concertScope == .my)
    }

    @Test("새로고침 중 필터 변경 시 이전 월별 fetch는 취소되고 최신 요청만 반영되어야 한다")
    func 새로고침_중_필터_변경_시_이전_월별_fetch는_취소되고_최신_요청만_반영되어야_한다() async throws {
        // Given
        let sut = HomeStore()
        try await seedJulyRange(sut)
        container.calendarRepository.fetchMonthResultQueue = [
            .success(makeMonth()),
            .success(makeMonth())
        ]
        container.calendarRepository.fetchMonthDelayNanoseconds = 200_000_000

        // When
        let refreshTask = Task { await sut.send(.calendar(.pullToRefresh)).wait() }
        try await Task.sleep(nanoseconds: 50_000_000)
        sut.send(.calendar(.myConcertsTapped))
        try await Task.sleep(nanoseconds: 250_000_000)
        await refreshTask.value

        // Then
        #expect(container.calendarRepository.fetchMonthParameterList.last?.concertType == .interest)
        #expect(sut.state.calendar.concertScope == .my)
        #expect(!sut.state.calendar.isLoadFailed)
        #expect(!sut.state.calendar.isInitialLoading)
    }

    @Test("dayScheduleRequested 성공 시 정렬된 목록과 모달이 표시되어야 한다")
    func dayScheduleRequested_성공_시_정렬된_목록과_모달이_표시되어야_한다() async throws {
        // Given
        let date = makeDate()
        let cancelled = makeEvent(
            concertID: 2,
            title: "취소",
            time: .init(hour: 10, minute: 0),
            status: .cancelled
        )
        let timed = makeEvent(
            concertID: 1,
            title: "정상",
            time: .init(hour: 18, minute: 0)
        )
        container.calendarRepository.fetchDayEventsResultQueue = [
            .success(CalendarDaySchedule(date: date, eventList: [cancelled, timed]))
        ]
        let sut = HomeStore()

        // When
        sut.send(.calendar(.dayScheduleRequested(date: date)))
        try await waitForAsyncTask()

        // Then
        #expect(sut.state.calendar.isDayScheduleModalPresented)
        #expect(
            sut.state.calendar.selectedDayTitle == DateFormatterService.string(from: date, type: .koreanMonthDayWeekday)
        )
        #expect(sut.state.calendar.dayScheduleEventList.map(\.concertID) == [1, 2])
    }

    @Test("dayScheduleRequested 성공 0건이면 빈 목록 모달이 표시되어야 한다")
    func dayScheduleRequested_성공_0건이면_빈_목록_모달이_표시되어야_한다() async throws {
        // Given
        let date = makeDate()
        container.calendarRepository.fetchDayEventsResultQueue = [
            .success(CalendarDaySchedule(date: date, eventList: []))
        ]
        let sut = HomeStore()

        // When
        sut.send(.calendar(.dayScheduleRequested(date: date)))
        try await waitForAsyncTask()

        // Then
        #expect(sut.state.calendar.isDayScheduleModalPresented)
        #expect(sut.state.calendar.dayScheduleEventList.isEmpty)
    }

    @Test("dayScheduleRequested 실패 시 모달 없이 실패 토스트가 설정되어야 한다")
    func dayScheduleRequested_실패_시_모달_없이_실패_토스트가_설정되어야_한다() async throws {
        // Given
        container.calendarRepository.fetchDayEventsResultQueue = [.failure(.serverError)]
        let sut = HomeStore()

        // When
        sut.send(.calendar(.dayScheduleRequested(date: makeDate())))
        try await waitForAsyncTask()

        // Then
        #expect(!sut.state.calendar.isDayScheduleModalPresented)
        #expect(
            sut.state.calendar.dayScheduleLoadFailedToastMessage
                == CalendarHomeConstants.dayScheduleLoadFailedToastMessage
        )
        #expect(sut.state.calendar.dayScheduleLoadFailedToastTrigger == 1)
    }

    @Test("일자 일정 모달 dismiss 시 presented가 false여야 한다")
    func 일자_일정_모달_dismiss_시_presented가_false여야_한다() async throws {
        // Given
        let date = makeDate()
        container.calendarRepository.fetchDayEventsResultQueue = [
            .success(CalendarDaySchedule(date: date, eventList: []))
        ]
        let sut = HomeStore()
        sut.send(.calendar(.dayScheduleRequested(date: date)))
        try await waitForAsyncTask()

        // When
        sut.send(.calendar(.dayScheduleModalDismissed))

        // Then
        #expect(!sut.state.calendar.isDayScheduleModalPresented)
    }

    @Test("monthChanged 동일 기간이면 fetch하지 않아야 한다")
    func monthChanged_동일_기간이면_fetch하지_않아야_한다() async throws {
        // Given
        let sut = HomeStore()
        try await seedJulyRange(sut)
        let callCount = container.calendarRepository.fetchMonthCallCount

        // When
        sut.send(.calendar(.monthChanged(startDate: "2026-07-01", endDate: "2026-07-31")))

        // Then
        #expect(container.calendarRepository.fetchMonthCallCount == callCount)
    }

    @Test("monthChanged 시 열린 일자 모달이 닫혀야 한다")
    func monthChanged_시_열린_일자_모달이_닫혀야_한다() async throws {
        // Given
        let date = makeDate()
        container.calendarRepository.fetchDayEventsResultQueue = [
            .success(CalendarDaySchedule(date: date, eventList: []))
        ]
        container.calendarRepository.fetchMonthResultQueue = [
            .success(CalendarMonth(dayList: []))
        ]
        let sut = HomeStore()
        sut.send(.calendar(.dayScheduleRequested(date: date)))
        try await waitForAsyncTask()
        #expect(sut.state.calendar.isDayScheduleModalPresented)

        // When
        sut.send(.calendar(.monthChanged(startDate: "2026-08-01", endDate: "2026-08-31")))

        // Then
        #expect(!sut.state.calendar.isDayScheduleModalPresented)
        try await waitForAsyncTask()
    }
}

// MARK: - Helpers

private extension CalendarHomeStoreTests {
    func waitForAsyncTask() async throws {
        try await Task.sleep(nanoseconds: 100_000_000)
    }

    func seedJulyRange(_ sut: HomeStore) async throws {
        container.calendarRepository.fetchMonthResultQueue = [.success(makeMonth())]
        sut.send(.calendar(.monthChanged(startDate: "2026-07-01", endDate: "2026-07-31")))
        try await waitForAsyncTask()
    }

    func makeMonth() -> CalendarMonth {
        CalendarMonth(dayList: [])
    }

    func makeDate() -> Date {
        Calendar.current.date(from: DateComponents(year: 2_026, month: 6, day: 20))!
    }

    func makeEvent(
        concertID: Int,
        title: String,
        time: CalendarEventTime?,
        status: CalendarDayEventStatus = .upcoming,
        type: CalendarDayEventType = .generalTicketing
    ) -> CalendarDayEvent {
        CalendarDayEvent(
            concertID: concertID,
            title: title,
            type: type,
            status: status,
            time: time,
            detail: .ticketOffice("NOL 티켓")
        )
    }
}
