//
//  RegisterFCMToken.swift
//  LivithNetworking
//
//  Created by 김진웅 on 5/27/26.
//  Copyright © 2026 Livith. All rights reserved.
//

// MARK: - 50. FCM 토큰 등록 / 51. FCM 토큰 삭제

import Foundation

public extension DTO.Request {
    struct RegisterFCMToken: Encodable {
        let token: String

        public init(token: String) {
            self.token = token
        }
    }

    struct DeleteFCMToken: Encodable {
        let token: String

        public init(token: String) {
            self.token = token
        }
    }
}
