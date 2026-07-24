//
//  InterestEntryAlert.swift
//  Domain
//
//  Created by Youjin Lee on 7/24/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

/// FR-06 관심 콘서트 결과 알림 항목. 카피(title/content)는 서버가 완성해 내려준다.
public struct InterestEntryAlert: Equatable {
    public let kind: Kind
    public let title: String
    public let content: String
    /// 요청 등록 성공 시 콘서트 상세 이동용
    public let concertID: Int?

    public init(
        kind: Kind,
        title: String,
        content: String,
        concertID: Int?
    ) {
        self.kind = kind
        self.title = title
        self.content = content
        self.concertID = concertID
    }
}

public extension InterestEntryAlert {
    enum Kind: String {
        case autoRemovedCompleted = "AUTO_REMOVED_COMPLETED"
        case autoRemovedCanceled = "AUTO_REMOVED_CANCELED"
        case requestRegistered = "REQUEST_REGISTERED"
        case requestFailed = "REQUEST_FAILED"
        /// 정의되지 않은 서버 kind 폴백
        case unknown
    }
}
