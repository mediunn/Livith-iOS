//
//  UpdateNotificationConsent.swift
//  LivithNetwork
//
//  Created by Youjin Lee on 2/6/26.
//  Copyright © 2026 Livith. All rights reserved.
//

// MARK: - 알림 동의 수정

public extension DTO.Request {
    struct UpdateNotificationConsent: Encodable {
        public let field: String
        public let isAgreed: Bool

        public init(field: String, isAgreed: Bool) {
            self.field = field
            self.isAgreed = isAgreed
        }
    }
}

public extension DTO.Response {
    struct UpdateNotificationConsent: Decodable {
        public let sender: String
        public let agreedAt: String
        public let message: String
    }
}
