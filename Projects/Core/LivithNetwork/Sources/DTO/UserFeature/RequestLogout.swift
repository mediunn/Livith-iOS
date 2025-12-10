//
//  RequestLogout.swift
//  network
//
//  Created by Youjin Lee on 10/14/25.
//  Copyright © 2025 Livith. All rights reserved.
//

// MARK: - 34. 로그아웃

public extension DTO.Request {
    struct RequestLogout: Encodable {
        public let refreshToken: String
    }
}

public extension DTO.Response {
    struct RequestLogout: Encodable {
        public let message: String
    }
}
