//
//  DeleteUser.swift
//  LivithNetworking
//
//  Created by 김진웅 on 5/27/26.
//  Copyright © 2026 Livith. All rights reserved.
//

// MARK: - 36. 회원 탈퇴

import Foundation

public extension DTO.Request {
    struct DeleteUser: Encodable {
        public let reason: String

        public init(reason: String) {
            self.reason = reason
        }
    }
}

public extension DTO.Response {
    struct DeleteUser: Decodable {
        public let message: String
    }
}
