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

extension Array where Element == InterestConcertEntryAlert {
    var autoCleanupAlertList: [InterestConcertEntryAlert] {
        filter(\.kind.isAutoCleanup)
    }

    var requestResultAlertList: [InterestConcertEntryAlert] {
        filter(\.kind.isRequestResult)
    }
}
