//
//  TokenExpirationPolicy.swift
//  LivithNetworking
//
//  Created by 김진웅 on 5/11/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

struct TokenExpirationPolicy: Sendable {
    public static let `default` = TokenExpirationPolicy(
        refreshTokenLifetime: 14 * 24 * 60 * 60
    )

    private let refreshTokenLifetime: TimeInterval

    public init(refreshTokenLifetime: TimeInterval) {
        self.refreshTokenLifetime = refreshTokenLifetime
    }

    public func isRefreshTokenExpired(
        issuedAt: Date,
        now: Date = .now
    ) -> Bool {
        let elapsedTime = now.timeIntervalSince(issuedAt)
        guard elapsedTime >= 0 else { return false }

        return elapsedTime > refreshTokenLifetime
    }
}
