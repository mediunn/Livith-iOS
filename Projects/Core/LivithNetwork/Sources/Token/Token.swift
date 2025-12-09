//
//  Token.swift
//  LivithNetwork
//
//  Created by 김진웅 on 12/7/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import Foundation

struct Token: Equatable {
    static let refreshTokenExpirationInterval: TimeInterval = 3 * 24 * 60 * 60
    
    let accessToken: String
    let refreshToken: String
    let refreshTokenIssuedAt: Date
    
    var refreshTokenIsExpired: Bool {
        return Date().timeIntervalSince(refreshTokenIssuedAt) > Self.refreshTokenExpirationInterval
    }
}
