//
//  InterestConcertEntryAlertPresentationTests.swift
//  HomeFeatureTests
//
//  Created by 김진웅 on 7/22/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Testing

import Domain

@testable import HomeFeature

@Suite("InterestConcertEntryAlertPresentation")
struct InterestConcertEntryAlertPresentationTests {

    @Test("kind는 자동 정리와 요청 결과로 구분되어야 한다")
    func kind는_자동_정리와_요청_결과로_구분되어야_한다() {
        #expect(InterestConcertEntryAlertKind.autoRemovedCompleted.isAutoCleanup)
        #expect(InterestConcertEntryAlertKind.autoRemovedCanceled.isAutoCleanup)
        #expect(!InterestConcertEntryAlertKind.requestRegistered.isAutoCleanup)
        #expect(InterestConcertEntryAlertKind.requestFailed.isRequestResult)
    }

    @Test("요청 결과 kind는 배지와 액션 라벨을 제공해야 한다")
    func 요청_결과_kind는_배지와_액션_라벨을_제공해야_한다() {
        #expect(InterestConcertEntryAlertKind.requestRegistered.badgeTitle == "추가 완료")
        #expect(InterestConcertEntryAlertKind.requestRegistered.actionTitle == "확인하기")
        #expect(!InterestConcertEntryAlertKind.requestRegistered.isFailure)

        #expect(InterestConcertEntryAlertKind.requestFailed.badgeTitle == "추가 실패")
        #expect(InterestConcertEntryAlertKind.requestFailed.actionTitle == "재요청")
        #expect(InterestConcertEntryAlertKind.requestFailed.isFailure)

        #expect(InterestConcertEntryAlertKind.autoRemovedCompleted.badgeTitle == nil)
        #expect(InterestConcertEntryAlertKind.autoRemovedCompleted.actionTitle == nil)
    }

    @Test("요청 결과 title은 19자를 넘으면 말줄임해야 한다")
    func 요청_결과_title은_19자를_넘으면_말줄임해야_한다() {
        // Given
        let longTitle = String(repeating: "가", count: 20)
        let shortTitle = String(repeating: "나", count: 19)
        let longAlert = InterestConcertEntryAlert(
            kind: .requestRegistered,
            title: longTitle,
            content: "나의 관심 콘서트에 추가됐어요",
            concertID: 1
        )
        let shortAlert = InterestConcertEntryAlert(
            kind: .requestFailed,
            title: shortTitle,
            content: "장르가 없어 관심 콘서트에 추가되지 않았어요",
            concertID: nil
        )
        let autoCleanupAlert = InterestConcertEntryAlert(
            kind: .autoRemovedCompleted,
            title: longTitle,
            content: "원 오크 록 내한 공연이 자동 정리 됐어요",
            concertID: nil
        )

        // When / Then
        #expect(longAlert.displayTitle == String(repeating: "가", count: 19) + "…")
        #expect(shortAlert.displayTitle == shortTitle)
        #expect(autoCleanupAlert.displayTitle == longTitle)
    }

    @Test("alertList는 kind 기준으로 섹션 목록을 나눠야 한다")
    func alertList는_kind_기준으로_섹션_목록을_나눠야_한다() {
        // Given
        let alertList = [
            InterestConcertEntryAlert(
                kind: .autoRemovedCompleted,
                title: "자동 정리된 공연 1",
                content: "원 오크 록 내한 공연이 자동 정리 됐어요",
                concertID: nil
            ),
            InterestConcertEntryAlert(
                kind: .requestRegistered,
                title: "natori 콘서트",
                content: "나의 관심 콘서트에 추가됐어요",
                concertID: 55
            ),
            InterestConcertEntryAlert(
                kind: .autoRemovedCanceled,
                title: "취소된 공연 1",
                content: "원 오크 록 내한 공연이 취소되어 자동 정리 됐어요",
                concertID: nil
            )
        ]

        // When
        let autoCleanupList = alertList.autoCleanupAlertList
        let requestResultList = alertList.requestResultAlertList

        // Then
        #expect(autoCleanupList.map(\.kind) == [.autoRemovedCompleted, .autoRemovedCanceled])
        #expect(requestResultList.map(\.kind) == [.requestRegistered])
    }
}
