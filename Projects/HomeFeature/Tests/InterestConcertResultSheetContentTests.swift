//
//  InterestConcertResultSheetContentTests.swift
//  HomeFeatureTests
//
//  Created by 김진웅 on 7/17/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Testing

@testable import HomeFeature
import Domain

@Suite("InterestConcertResultSheetContent")
struct InterestConcertResultSheetContentTests {

    @Test("EntryAlert kind에 따라 자동 정리·요청 섹션으로 분류해야 한다")
    func entryAlertKind에_따라_자동_정리_요청_섹션으로_분류해야_한다() {
        // Given
        let alerts = [
            makeAlert(kind: .autoRemovedCompleted, title: "자동 정리된 공연 2", content: "오크 록 내한 공연 외 1건이 자동 정리 됐어요"),
            makeAlert(kind: .autoRemovedCanceled, title: "취소된 공연 1", content: "오크 록 내한 공연이 취소되어 자동 정리 됐어요"),
            makeAlert(kind: .requestRegistered, title: "natori 콘서트", content: "나의 관심 콘서트에 추가됐어요", concertID: 55),
            makeAlert(kind: .requestFailed, title: "natori 콘서트", content: "정확한 정보가 부족하여 추가되지 않았어요")
        ]

        // When
        let content = InterestConcertResultSheetContent(alerts: alerts)

        // Then
        #expect(content.autoCleanupItemList.count == 2)
        #expect(content.autoCleanupItemList[0].title == "자동 정리된 공연 2")
        #expect(content.autoCleanupItemList[0].description == "오크 록 내한 공연 외 1건이 자동 정리 됐어요")
        #expect(content.autoCleanupItemList[1].title == "취소된 공연 1")

        #expect(content.requestResultItemList.count == 2)
        #expect(content.requestResultItemList[0].outcome == .added)
        #expect(content.requestResultItemList[0].concertTitle == "natori 콘서트")
        #expect(content.requestResultItemList[0].description == "나의 관심 콘서트에 추가됐어요")
        #expect(content.requestResultItemList[0].concertID == 55)
        #expect(content.requestResultItemList[1].outcome == .failed)
        #expect(content.requestResultItemList[1].concertID == nil)
    }

    @Test("정의되지 않은 kind 알림은 표시 목록에서 제외해야 한다")
    func 정의되지_않은_kind_알림은_표시_목록에서_제외해야_한다() {
        // Given
        let alerts = [
            makeAlert(kind: .unknown, title: "제목", content: "내용"),
            makeAlert(kind: .requestRegistered, title: "natori 콘서트", content: "나의 관심 콘서트에 추가됐어요", concertID: 55)
        ]

        // When
        let content = InterestConcertResultSheetContent(alerts: alerts)

        // Then
        #expect(content.autoCleanupItemList.isEmpty)
        #expect(content.requestResultItemList.count == 1)
    }

    @Test("요청 결과 outcome별 배지·액션 카피를 만들어야 한다")
    func 요청_결과_outcome별_배지_액션_카피를_만들어야_한다() {
        // Given
        let content = InterestConcertResultSheetContent(alerts: [
            makeAlert(kind: .requestRegistered, title: "콘서트", content: "나의 관심 콘서트에 추가됐어요", concertID: 1),
            makeAlert(kind: .requestFailed, title: "콘서트", content: "지난 공연으로 관심 콘서트에 추가되지 않았어요")
        ])

        // When
        let added = content.requestResultItemList[0]
        let failed = content.requestResultItemList[1]

        // Then
        #expect(added.badgeTitle == "추가 완료")
        #expect(added.actionTitle == "확인하기")
        #expect(!added.isFailure)
        #expect(failed.badgeTitle == "추가 실패")
        #expect(failed.actionTitle == "재요청")
        #expect(failed.isFailure)
    }

    @Test("두 섹션이 모두 비어 있을 때만 isEmpty여야 한다")
    func 두_섹션이_모두_비어_있을_때만_isEmpty여야_한다() {
        // Given & When & Then
        #expect(InterestConcertResultSheetContent(alerts: []).isEmpty)
        #expect(InterestConcertResultSheetContent(alerts: [makeAlert(kind: .unknown, title: "t", content: "c")]).isEmpty)
        #expect(!InterestConcertResultSheetContent(alerts: [makeAlert(kind: .autoRemovedCompleted, title: "t", content: "c")]).isEmpty)
        #expect(!InterestConcertResultSheetContent(alerts: [makeAlert(kind: .requestFailed, title: "t", content: "c")]).isEmpty)
    }
}

// MARK: - Helper

private extension InterestConcertResultSheetContentTests {
    func makeAlert(
        kind: InterestEntryAlert.Kind,
        title: String,
        content: String,
        concertID: Int? = nil
    ) -> InterestEntryAlert {
        InterestEntryAlert(kind: kind, title: title, content: content, concertID: concertID)
    }
}
