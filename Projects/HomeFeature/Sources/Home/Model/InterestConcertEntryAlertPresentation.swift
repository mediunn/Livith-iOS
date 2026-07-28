//
//  InterestConcertEntryAlertPresentation.swift
//  HomeFeature
//
//  Created by 김진웅 on 7/22/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Domain

extension InterestConcertEntryAlertKind {
    var isAutoCleanup: Bool {
        switch self {
        case .autoRemovedCompleted, .autoRemovedCanceled:
            return true
        case .requestRegistered, .requestFailed:
            return false
        }
    }

    var isRequestResult: Bool {
        !isAutoCleanup
    }

    var isFailure: Bool {
        self == .requestFailed
    }

    var badgeTitle: String? {
        switch self {
        case .requestRegistered:
            return "추가 완료"
        case .requestFailed:
            return "추가 실패"
        case .autoRemovedCompleted, .autoRemovedCanceled:
            return nil
        }
    }

    var actionTitle: String? {
        switch self {
        case .requestRegistered:
            return "확인하기"
        case .requestFailed:
            return "재요청"
        case .autoRemovedCompleted, .autoRemovedCanceled:
            return nil
        }
    }
}

extension InterestConcertEntryAlert {
    /// 요청 결과 카드 공연명. Figma: 공백 포함 24자 초과 시 말줄임. 자동 정리는 원문 유지.
    var displayTitle: String {
        switch kind {
        case .autoRemovedCompleted, .autoRemovedCanceled:
            return title
        case .requestRegistered, .requestFailed:
            return title.truncatedForRequestConcertName
        }
    }
}

private extension String {
    static let requestConcertNameMaxLength = 24

    var truncatedForRequestConcertName: String {
        guard count > Self.requestConcertNameMaxLength else { return self }
        return String(prefix(Self.requestConcertNameMaxLength)) + "..."
    }
}

extension Array where Element == InterestConcertEntryAlert {
    var autoCleanupAlertList: [InterestConcertEntryAlert] {
        filter(\.kind.isAutoCleanup)
    }

    var requestResultAlertList: [InterestConcertEntryAlert] {
        filter(\.kind.isRequestResult)
    }
}
