//
//  InterestConcertResultSheetContent.swift
//  HomeFeature
//
//  Created by 김진웅 on 7/17/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

import Domain

/// FR-06 관심 콘서트 결과 시트 표시용 모델. 카피(title/content)는 서버가 완성해 내려준다.
struct InterestConcertResultSheetContent: Equatable {
    var autoCleanupItemList: [AutoCleanupItem]
    var requestResultItemList: [RequestResultItem]

    init(alerts: [InterestEntryAlert]) {
        var autoCleanupItemList: [AutoCleanupItem] = []
        var requestResultItemList: [RequestResultItem] = []

        for (index, alert) in alerts.enumerated() {
            switch alert.kind {
            case .autoRemovedCompleted, .autoRemovedCanceled:
                autoCleanupItemList.append(
                    AutoCleanupItem(
                        id: "auto-\(index)",
                        title: alert.title,
                        description: alert.content
                    )
                )
            case .requestRegistered, .requestFailed:
                requestResultItemList.append(
                    RequestResultItem(
                        id: "request-\(index)",
                        outcome: alert.kind == .requestRegistered ? .added : .failed,
                        concertTitle: alert.title,
                        description: alert.content,
                        concertID: alert.concertID
                    )
                )
            case .unknown:
                continue
            }
        }

        self.autoCleanupItemList = autoCleanupItemList
        self.requestResultItemList = requestResultItemList
    }

    var isEmpty: Bool {
        autoCleanupItemList.isEmpty && requestResultItemList.isEmpty
    }
}

// MARK: - Auto Cleanup

extension InterestConcertResultSheetContent {
    /// 자동 정리 / 취소 정리 카드. 탭 액션 없음.
    struct AutoCleanupItem: Equatable, Identifiable {
        let id: String
        let title: String
        let description: String
    }
}

// MARK: - Request Result

extension InterestConcertResultSheetContent {
    /// 요청한 공연 추가 결과 카드.
    struct RequestResultItem: Equatable, Identifiable {
        let id: String
        let outcome: Outcome
        let concertTitle: String
        let description: String
        /// 요청 등록 성공 시 콘서트 상세 이동용
        let concertID: Int?

        enum Outcome: Equatable {
            case added
            case failed
        }

        var isFailure: Bool {
            outcome == .failed
        }

        var badgeTitle: String {
            switch outcome {
            case .added:
                return "추가 완료"
            case .failed:
                return "추가 실패"
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

// MARK: - Stub

extension InterestConcertResultSheetContent {
    /// Figma FR-06 케이스 샘플. Preview 전용.
    static let stub = InterestConcertResultSheetContent(alerts: [
        InterestEntryAlert(
            kind: .autoRemovedCompleted,
            title: "자동 정리된 공연 4",
            content: "원 오크 록 내한 공연 외 3건이 자동 정리 됐어요",
            concertID: nil
        ),
        InterestEntryAlert(
            kind: .autoRemovedCanceled,
            title: "취소된 공연 1",
            content: "원 오크 록 내한 공연이 취소되어 자동 정리 됐어요",
            concertID: nil
        ),
        InterestEntryAlert(
            kind: .requestRegistered,
            title: "[19자 내 공연명 이후 말줄임..] 콘서트",
            content: "나의 관심 콘서트에 추가됐어요",
            concertID: 1
        ),
        InterestEntryAlert(
            kind: .requestFailed,
            title: "[19자 내 공연명 이후 말줄임..] 콘서트",
            content: "정확한 정보가 부족하여 추가되지 않았어요",
            concertID: nil
        )
    ])
}
