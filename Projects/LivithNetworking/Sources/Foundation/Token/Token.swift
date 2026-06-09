//
//  Token.swift
//  LivithNetworking
//
//  Created by 김진웅 on 5/11/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

public struct Token: Codable, Equatable, Sendable {
    public let accessToken: String
    public let refreshToken: String
    public let refreshTokenIssuedAt: Date

    public init(
        accessToken: String,
        refreshToken: String,
        refreshTokenIssuedAt: Date
    ) {
        self.accessToken = accessToken
        self.refreshToken = refreshToken
        self.refreshTokenIssuedAt = refreshTokenIssuedAt
    }
}
