//
//  InterestConcertEntryAlert.swift
//  Domain
//
//  Created by 김진웅 on 7/22/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

// MARK: - InterestConcertEntryAlertKind

public enum InterestConcertEntryAlertKind: Equatable, CaseIterable {
    case autoRemovedCompleted
    case autoRemovedCanceled
    case requestRegistered
    case requestFailed
}

// MARK: - InterestConcertEntryAlert

public struct InterestConcertEntryAlert: Equatable {

    // MARK: - Properties

    public let kind: InterestConcertEntryAlertKind
    public let title: String
    public let content: String
    public let concertID: Int?

    // MARK: - Initializer

    public init(
        kind: InterestConcertEntryAlertKind,
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
