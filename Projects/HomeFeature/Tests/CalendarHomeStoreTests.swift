//
//  CalendarHomeStoreTests.swift
//  HomeFeatureTests
//
//  Created by 김진웅 on 7/19/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Testing

@testable import HomeFeature

@MainActor
@Suite("CalendarHomeStore")
struct CalendarHomeStoreTests {

  @Test("초기 상태에서 예매일·공연일은 on이고 공연 범위는 전체 공연이어야 한다")
  func 초기_상태에서_예매일_공연일은_on이고_공연_범위는_전체_공연이어야_한다() {
    // Given
    let sut = CalendarHomeStore()

    // Then
    #expect(sut.state.isTicketingDateSelected)
    #expect(sut.state.isPerformanceDateSelected)
    #expect(sut.state.concertScope == .all)
    #expect(sut.state.selectionBlockedToastMessage.isEmpty)
    #expect(sut.state.isLoadFailed)
  }

  @Test("예매일 칩 탭 시 예매일 선택 상태가 토글되어야 한다")
  func 예매일_칩_탭_시_예매일_선택_상태가_토글되어야_한다() {
    // Given
    let sut = CalendarHomeStore()

    // When
    sut.send(.ticketingDateTapped)

    // Then
    #expect(!sut.state.isTicketingDateSelected)
    #expect(sut.state.isPerformanceDateSelected)
    #expect(sut.state.selectionBlockedToastMessage.isEmpty)
  }

  @Test("공연일 칩 탭 시 공연일 선택 상태가 토글되어야 한다")
  func 공연일_칩_탭_시_공연일_선택_상태가_토글되어야_한다() {
    // Given
    let sut = CalendarHomeStore()

    // When
    sut.send(.performanceDateTapped)

    // Then
    #expect(sut.state.isTicketingDateSelected)
    #expect(!sut.state.isPerformanceDateSelected)
    #expect(sut.state.selectionBlockedToastMessage.isEmpty)
  }

  @Test("마지막 on인 예매일 칩 off 시도 시 상태는 유지되고 선택 불가 토스트가 설정되어야 한다")
  func 마지막_on인_예매일_칩_off_시도_시_상태는_유지되고_선택_불가_토스트가_설정되어야_한다() {
    // Given
    let sut = CalendarHomeStore()
    sut.send(.performanceDateTapped)

    // When
    sut.send(.ticketingDateTapped)

    // Then
    #expect(sut.state.isTicketingDateSelected)
    #expect(!sut.state.isPerformanceDateSelected)
    #expect(sut.state.selectionBlockedToastMessage == CalendarHomeStore.Constants.selectionBlockedToastMessage)
  }

  @Test("마지막 on인 공연일 칩 off 시도 시 상태는 유지되고 선택 불가 토스트가 설정되어야 한다")
  func 마지막_on인_공연일_칩_off_시도_시_상태는_유지되고_선택_불가_토스트가_설정되어야_한다() {
    // Given
    let sut = CalendarHomeStore()
    sut.send(.ticketingDateTapped)

    // When
    sut.send(.performanceDateTapped)

    // Then
    #expect(!sut.state.isTicketingDateSelected)
    #expect(sut.state.isPerformanceDateSelected)
    #expect(sut.state.selectionBlockedToastMessage == CalendarHomeStore.Constants.selectionBlockedToastMessage)
  }

  @Test("전체 공연 칩 탭 시 공연 범위가 전체 공연으로 전환되어야 한다")
  func 전체_공연_칩_탭_시_공연_범위가_전체_공연으로_전환되어야_한다() {
    // Given
    let sut = CalendarHomeStore()
    sut.send(.myConcertsTapped)

    // When
    sut.send(.allConcertsTapped)

    // Then
    #expect(sut.state.concertScope == .all)
  }

  @Test("내 공연 칩 탭 시 공연 범위가 내 공연으로 전환되어야 한다")
  func 내_공연_칩_탭_시_공연_범위가_내_공연으로_전환되어야_한다() {
    // Given
    let sut = CalendarHomeStore()

    // When
    sut.send(.myConcertsTapped)

    // Then
    #expect(sut.state.concertScope == .my)
  }

  @Test("선택 불가 토스트 dismiss 시 메시지가 클리어되어야 한다")
  func 선택_불가_토스트_dismiss_시_메시지가_클리어되어야_한다() {
    // Given
    let sut = CalendarHomeStore()
    sut.send(.performanceDateTapped)
    sut.send(.ticketingDateTapped)

    // When
    sut.send(.onSelectionBlockedToastDisappear)

    // Then
    #expect(sut.state.selectionBlockedToastMessage.isEmpty)
    #expect(sut.state.selectionBlockedToastTrigger == 1)
  }

  @Test("연속 선택 불가 시도 시 토스트 트리거가 증가해야 한다")
  func 연속_선택_불가_시도_시_토스트_트리거가_증가해야_한다() {
    // Given
    let sut = CalendarHomeStore()
    sut.send(.performanceDateTapped)
    sut.send(.ticketingDateTapped)
    let firstTrigger = sut.state.selectionBlockedToastTrigger

    // When
    sut.send(.onSelectionBlockedToastDisappear)
    sut.send(.ticketingDateTapped)

    // Then
    #expect(sut.state.selectionBlockedToastTrigger == firstTrigger + 1)
  }

  @Test("새로고침 시 필터 선택 상태는 유지되어야 한다")
  func 새로고침_시_필터_선택_상태는_유지되어야_한다() async {
    // Given
    let sut = CalendarHomeStore()
    sut.send(.performanceDateTapped)
    sut.send(.myConcertsTapped)

    // When
    await sut.performRefresh()

    // Then
    #expect(sut.state.isTicketingDateSelected)
    #expect(!sut.state.isPerformanceDateSelected)
    #expect(sut.state.concertScope == .my)
  }

  @Test("일자 일정 모달 오픈 시 정렬된 목록과 presented 상태가 true여야 한다")
  func 일자_일정_모달_오픈_시_정렬된_목록과_presented_상태가_true여야_한다() {
    // Given
    let sut = CalendarHomeStore()
    let cancelled = CalendarDayScheduleItem(
      id: "c",
      kind: .ticketing,
      title: "취소",
      subtitle: "NOL",
      time: .init(hour: 10, minute: 0),
      isCancelled: true
    )
    let timed = CalendarDayScheduleItem(
      id: "t",
      kind: .performance,
      title: "정상",
      subtitle: "잠실",
      time: .init(hour: 18, minute: 0),
      isCancelled: false
    )

    // When
    sut.send(.dayScheduleModalOpened(dayTitle: "6월 20일 수요일", items: [cancelled, timed]))

    // Then
    #expect(sut.state.isDayScheduleModalPresented)
    #expect(sut.state.selectedDayTitle == "6월 20일 수요일")
    #expect(sut.state.dayScheduleItems.map(\.id) == ["t", "c"])
  }

  @Test("일자 일정 모달 dismiss 시 presented가 false여야 한다")
  func 일자_일정_모달_dismiss_시_presented가_false여야_한다() {
    // Given
    let sut = CalendarHomeStore()
    sut.send(.dayScheduleModalOpened(dayTitle: "6월 20일 수요일", items: []))

    // When
    sut.send(.dayScheduleModalDismissed)

    // Then
    #expect(!sut.state.isDayScheduleModalPresented)
  }

  @Test("빈 일정으로 모달 오픈 시 dayScheduleItems가 비어 있어야 한다")
  func 빈_일정으로_모달_오픈_시_dayScheduleItems가_비어_있어야_한다() {
    // Given
    let sut = CalendarHomeStore()

    // When
    sut.send(.dayScheduleModalOpened(dayTitle: "6월 20일 수요일", items: []))

    // Then
    #expect(sut.state.isDayScheduleModalPresented)
    #expect(sut.state.dayScheduleItems.isEmpty)
  }
}
