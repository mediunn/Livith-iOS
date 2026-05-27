//
//  UpdateNotificationConsent.swift
//  LivithNetworking
//
//  Created by 김진웅 on 5/27/26.
//  Copyright © 2026 Livith. All rights reserved.
//

// MARK: - 45. 알림 동의 / 46. 마케팅 동의

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
