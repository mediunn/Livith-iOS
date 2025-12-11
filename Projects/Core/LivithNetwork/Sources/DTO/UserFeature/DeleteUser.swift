//
//  DeleteUser.swift
//  network
//
//  Created by Youjin Lee on 10/15/25.
//  Copyright © 2025 Livith. All rights reserved.
//

// MARK: - 35. 회원탈퇴

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
