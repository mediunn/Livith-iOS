//
//  UpdateUserNickname.swift
//  LivithNetworking
//
//  Created by 김진웅 on 5/27/26.
//  Copyright © 2026 Livith. All rights reserved.
//

// MARK: - 33. 닉네임 수정

import Foundation

public extension DTO.Request {
    struct UpdateUserNickname: Encodable {
        public let nickname: String

        public init(nickname: String) {
            self.nickname = nickname
        }
    }
}

public extension DTO.Response {
    struct UpdateUserNickname: Decodable {
        public let id: Int
        public let interestConcertID: Int?
        public let provider: String
        public let providerID: String
        public let email: String?
        public let nickname: String
        public let marketingConsent: Bool

        enum CodingKeys: String, CodingKey {
            case id
            case interestConcertID = "interestConcertId"
            case providerID = "providerId"
            case provider, email, nickname, marketingConsent
        }
    }
}
