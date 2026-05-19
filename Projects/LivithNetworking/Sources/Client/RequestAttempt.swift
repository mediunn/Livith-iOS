//
//  RequestAttempt.swift
//  LivithNetworking
//
//  Created by 김진웅 on 5/13/26.
//  Copyright © 2026 Livith. All rights reserved.
//

struct RequestAttempt: Sendable {
    let retryCount: Int
    let fallbackCount: Int
    let skipsETag: Bool

    init(
        retryCount: Int = 0,
        fallbackCount: Int = 0,
        skipsETag: Bool = false
    ) {
        self.retryCount = retryCount
        self.fallbackCount = fallbackCount
        self.skipsETag = skipsETag
    }

    var canRetry: Bool {
        retryCount == 0
    }

    var canFallback: Bool {
        fallbackCount == 0
    }

    func retrying() -> RequestAttempt {
        RequestAttempt(
            retryCount: retryCount + 1,
            fallbackCount: fallbackCount,
            skipsETag: skipsETag
        )
    }

    func fallingBack() -> RequestAttempt {
        RequestAttempt(
            retryCount: retryCount,
            fallbackCount: fallbackCount + 1,
            skipsETag: true
        )
    }
}
