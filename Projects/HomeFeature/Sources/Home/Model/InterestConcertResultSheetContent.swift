//
//  InterestConcertResultSheetContent.swift
//  HomeFeature
//
//  Created by 김진웅 on 7/17/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

/// FR-06 관심 콘서트 결과 시트 표시용 모델.
struct InterestConcertResultSheetContent: Equatable {
    var autoCleanupItemList: [AutoCleanupItem]
    var requestResultItemList: [RequestResultItem]
}

// MARK: - Auto Cleanup

extension InterestConcertResultSheetContent {
    /// 자동 정리 / 취소 정리 카드. 탭 액션 없음.
    struct AutoCleanupItem: Equatable, Identifiable {
        let id: String
        let kind: Kind
        /// 정리된 공연 개수 N
        let count: Int
        /// 가장 먼저 정리된 콘서트명
        let representativeConcertTitle: String

        enum Kind: Equatable {
            /// “자동 정리된 공연 N”
            case completed
            /// “취소된 공연 N”
            case canceled
        }

        var title: String {
            "\(kind.titlePrefix) \(count)"
        }

        var description: String {
            kind.description(
                representativeConcertTitle: representativeConcertTitle,
                count: count
            )
        }
    }
}

extension InterestConcertResultSheetContent.AutoCleanupItem.Kind {
    var titlePrefix: String {
        switch self {
        case .completed:
            return "자동 정리된 공연"
        case .canceled:
            return "취소된 공연"
        }
    }

    func description(representativeConcertTitle: String, count: Int) -> String {
        switch self {
        case .completed:
            if count <= 1 {
                return "\(representativeConcertTitle)이 자동 정리 됐어요"
            }
            return "\(representativeConcertTitle) 외 \(count - 1)건이 자동 정리 됐어요"
        case .canceled:
            if count <= 1 {
                return "\(representativeConcertTitle)이 취소되어 자동 정리 됐어요"
            }
            return "\(representativeConcertTitle) 외 \(count - 1)건이 취소되어 자동 정리 됐어요"
        }
    }
}

// MARK: - Request Result

extension InterestConcertResultSheetContent {
    /// 요청한 공연 추가 결과 카드.
    struct RequestResultItem: Equatable, Identifiable {
        let id: String
        let outcome: Outcome
        let concertTitle: String

        enum Outcome: Equatable {
            case added
            case failed(FailureReason)
        }

        enum FailureReason: Equatable, CaseIterable {
            /// 지난 공연 신청
            case pastConcert
            /// 장르 부재
            case missingGenre
            /// 정보 부족
            case insufficientInfo
        }

        var isFailure: Bool {
            if case .failed = outcome { return true }
            return false
        }

        var badgeTitle: String {
            switch outcome {
            case .added:
                return "추가 완료"
            case .failed:
                return "추가 실패"
            }
        }

        var description: String {
            switch outcome {
            case .added:
                return "나의 관심 콘서트에 추가됐어요"
            case .failed(let reason):
                return reason.description
            }
        }

        var actionTitle: String {
            switch outcome {
            case .added:
                return "확인하기"
            case .failed:
                return "재요청"
            }
        }
    }
}

extension InterestConcertResultSheetContent.RequestResultItem.FailureReason {
    var description: String {
        switch self {
        case .pastConcert:
            return "지난 공연으로 관심 콘서트에 추가되지 않았어요"
        case .missingGenre:
            return "장르가 없어 관심 콘서트에 추가되지 않았어요"
        case .insufficientInfo:
            return "정확한 정보가 부족하여 추가되지 않았어요"
        }
    }
}

// MARK: - Stub

extension InterestConcertResultSheetContent {
    private static let stubConcertTitle = "[19자 내 공연명 이후 말줄임..] 콘서트"

    /// Figma FR-06에서 설명하는 모든 케이스 샘플 (자동 정리 1/N, 취소 1/N, 요청 성공, 실패 3종).
    static let stub = InterestConcertResultSheetContent(
        autoCleanupItemList: [
            AutoCleanupItem(
                id: "auto-completed-many",
                kind: .completed,
                count: 4,
                representativeConcertTitle: "원 오크 록 내한 공연"
            ),
            AutoCleanupItem(
                id: "auto-completed-one",
                kind: .completed,
                count: 1,
                representativeConcertTitle: "원 오크 록 내한 공연"
            ),
            AutoCleanupItem(
                id: "auto-canceled-many",
                kind: .canceled,
                count: 2,
                representativeConcertTitle: "원 오크 록 내한 공연"
            ),
            AutoCleanupItem(
                id: "auto-canceled-one",
                kind: .canceled,
                count: 1,
                representativeConcertTitle: "원 오크 록 내한 공연"
            )
        ],
        requestResultItemList: [
            RequestResultItem(
                id: "request-added",
                outcome: .added,
                concertTitle: stubConcertTitle
            ),
            RequestResultItem(
                id: "request-failed-past",
                outcome: .failed(.pastConcert),
                concertTitle: stubConcertTitle
            ),
            RequestResultItem(
                id: "request-failed-genre",
                outcome: .failed(.missingGenre),
                concertTitle: stubConcertTitle
            ),
            RequestResultItem(
                id: "request-failed-info",
                outcome: .failed(.insufficientInfo),
                concertTitle: stubConcertTitle
            )
        ]
    )
}
