//
//  InterestConcertResultSheetContentTests.swift
//  HomeFeatureTests
//
//  Created by 김진웅 on 7/17/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Testing
@testable import HomeFeature

@Suite("InterestConcertResultSheetContent")
struct InterestConcertResultSheetContentTests {

    @Test("자동 정리 1건·다건 카피를 Figma 규칙으로 만들어야 한다")
    func autoCleanupCompletedCopy() {
        let one = InterestConcertResultSheetContent.AutoCleanupItem(
            id: "1",
            kind: .completed,
            count: 1,
            representativeConcertTitle: "원 오크 록 내한 공연"
        )
        let many = InterestConcertResultSheetContent.AutoCleanupItem(
            id: "2",
            kind: .completed,
            count: 4,
            representativeConcertTitle: "원 오크 록 내한 공연"
        )

        #expect(one.title == "자동 정리된 공연 1")
        #expect(one.description == "원 오크 록 내한 공연이 자동 정리 됐어요")
        #expect(many.title == "자동 정리된 공연 4")
        #expect(many.description == "원 오크 록 내한 공연 외 3건이 자동 정리 됐어요")
    }

    @Test("취소 정리 1건·다건 카피를 Figma 규칙으로 만들어야 한다")
    func autoCleanupCanceledCopy() {
        let one = InterestConcertResultSheetContent.AutoCleanupItem(
            id: "1",
            kind: .canceled,
            count: 1,
            representativeConcertTitle: "원 오크 록 내한 공연"
        )
        let many = InterestConcertResultSheetContent.AutoCleanupItem(
            id: "2",
            kind: .canceled,
            count: 2,
            representativeConcertTitle: "원 오크 록 내한 공연"
        )

        #expect(one.title == "취소된 공연 1")
        #expect(one.description == "원 오크 록 내한 공연이 취소되어 자동 정리 됐어요")
        #expect(many.title == "취소된 공연 2")
        #expect(many.description == "원 오크 록 내한 공연 외 1건이 취소되어 자동 정리 됐어요")
    }

    @Test("요청 성공·실패 사유별 배지·설명·액션 카피를 만들어야 한다")
    func requestResultCopy() {
        let added = InterestConcertResultSheetContent.RequestResultItem(
            id: "a",
            outcome: .added,
            concertTitle: "콘서트"
        )
        #expect(added.badgeTitle == "추가 완료")
        #expect(added.description == "나의 관심 콘서트에 추가됐어요")
        #expect(added.actionTitle == "확인하기")
        #expect(!added.isFailure)

        let past = InterestConcertResultSheetContent.RequestResultItem(
            id: "p",
            outcome: .failed(.pastConcert),
            concertTitle: "콘서트"
        )
        #expect(past.badgeTitle == "추가 실패")
        #expect(past.description == "지난 공연으로 관심 콘서트에 추가되지 않았어요")
        #expect(past.actionTitle == "재요청")
        #expect(past.isFailure)

        let genre = InterestConcertResultSheetContent.RequestResultItem(
            id: "g",
            outcome: .failed(.missingGenre),
            concertTitle: "콘서트"
        )
        #expect(genre.description == "장르가 없어 관심 콘서트에 추가되지 않았어요")

        let info = InterestConcertResultSheetContent.RequestResultItem(
            id: "i",
            outcome: .failed(.insufficientInfo),
            concertTitle: "콘서트"
        )
        #expect(info.description == "정확한 정보가 부족하여 추가되지 않았어요")
    }

    @Test("stub은 Figma 전체 케이스(자동 정리 1/N·취소 1/N·요청 성공·실패 3종)를 포함해야 한다")
    func stubContainsAllCases() {
        let stub = InterestConcertResultSheetContent.stub

        #expect(stub.autoCleanupItemList.count == 4)
        #expect(stub.autoCleanupItemList.map(\.kind) == [.completed, .completed, .canceled, .canceled])
        #expect(stub.autoCleanupItemList.map(\.count) == [4, 1, 2, 1])

        #expect(stub.requestResultItemList.count == 4)
        #expect(stub.requestResultItemList[0].outcome == .added)
        #expect(stub.requestResultItemList[1].outcome == .failed(.pastConcert))
        #expect(stub.requestResultItemList[2].outcome == .failed(.missingGenre))
        #expect(stub.requestResultItemList[3].outcome == .failed(.insufficientInfo))
    }
}
