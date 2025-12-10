//
//  FetchUserInfo.swift
//  network
//
//  Created by Youjin Lee on 10/12/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import Foundation

// MARK: - 31. 사용자 정보 조회

public extension DTO.Response {
    struct FetchUserInfo: Decodable {
        public let accessToken: String
        public let refreshToken: String
        public let user: User
    }
    
    struct User: Decodable {
        public let id: String
        public let interestConcertID: Int?
        public let provider: String
        public let providerID: String
        public let email: String?
        public let nickname: String
        public let marketingConsent: Bool
        
        enum CodingKeys: String, CodingKey {
            case id
            case interestConcertID = "interestConcertId"
            case provider, providerID, email, nickname, marketingConsent
        }
    }
}
