//
//  RequestAttempt.swift
//  LivithNetworking
//
//  Created by 김진웅 on 5/13/26.
//  Copyright © 2026 Livith. All rights reserved.
//

struct RequestAttempt: Sendable {
    let retryCount: Int

    init(retryCount: Int = 0) {
        self.retryCount = retryCount
    }

    var canRetry: Bool {
        retryCount == 0
    }

    func retrying() -> RequestAttempt {
        RequestAttempt(retryCount: retryCount + 1)
    }
}
