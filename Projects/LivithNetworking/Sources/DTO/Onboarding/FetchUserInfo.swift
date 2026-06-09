//
//  FetchUserInfo.swift
//  LivithNetworking
//
//  Created by 김진웅 on 5/27/26.
//  Copyright © 2026 Livith. All rights reserved.
//

// MARK: - 31. 유저 정보 조회

import Foundation

public extension DTO.Response {
    struct FetchUserInfo: Codable {
        public let id: Int
        public let provider: String
        public let providerID: String?
        public let email: String?
        public let nickname: String
        public let marketingConsent: Bool
        public let hasPreferredGenre: Bool

        enum CodingKeys: String, CodingKey {
            case id
            case providerID = "providerId"
            case provider, email, nickname, marketingConsent, hasPreferredGenre
        }
    }
}
