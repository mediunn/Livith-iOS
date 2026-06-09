//
//  RequestLogout.swift
//  LivithNetworking
//
//  Created by 김진웅 on 5/27/26.
//  Copyright © 2026 Livith. All rights reserved.
//

// MARK: - 35. 로그아웃

import Foundation

public extension DTO.Request {
    struct RequestLogout: Encodable {
        public let refreshToken: String

        public init(refreshToken: String) {
            self.refreshToken = refreshToken
        }
    }
}

public extension DTO.Response {
    struct RequestLogout: Decodable {
        public let message: String
    }
}
