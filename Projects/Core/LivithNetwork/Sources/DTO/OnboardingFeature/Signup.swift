//
//  Signup.swift
//  LivithNetwork
//
//  Created by 김진웅 on 12/12/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import Foundation

// MARK: - 30. 회원가입

public extension DTO.Request {
    struct Signup: Encodable {
        public let nickname: String
        public let marketingConsent: Bool
        public let providerID: String
        public let provider: String
        public let email: String?
        
        enum CodingKeys: String, CodingKey {
            case nickname, marketingConsent, provider, email
            case providerID = "providerId"
        }
    }
}

public extension DTO.Response {
    struct Signup: Decodable {
        public let accessToken: String
        public let refreshToken: String
        public let user: DTO.Response.FetchUserInfo
    }
}
