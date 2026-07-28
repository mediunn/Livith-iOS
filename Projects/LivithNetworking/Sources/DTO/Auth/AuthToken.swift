//
//  AuthToken.swift
//  LivithNetworking
//
//  Created by 김진웅 on 5/13/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

// 29. 토큰 재발급

public extension DTO.Request {
    struct Token: Encodable {
        public let refreshToken: String

        public init(refreshToken: String) {
            self.refreshToken = refreshToken
        }
    }
}

public extension DTO.Response {
    struct Token: Decodable {
        public let accessToken: String
        public let refreshToken: String

        public init(
            accessToken: String,
            refreshToken: String
        ) {
            self.accessToken = accessToken
            self.refreshToken = refreshToken
        }
    }
}
