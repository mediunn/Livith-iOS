//
//  Token.swift
//  LivithNetwork
//
//  Created by 김진웅 on 12/7/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import Foundation

struct Token: Equatable {
    let accessToken: String
    let refreshToken: String
    let refreshTokenIssuedAt: Date
    
    var isExpired: Bool {
        let threeDaysInSeconds: TimeInterval = 3 * 24 * 60 * 60
        return Date().timeIntervalSince(refreshTokenIssuedAt) > threeDaysInSeconds
    }
}
