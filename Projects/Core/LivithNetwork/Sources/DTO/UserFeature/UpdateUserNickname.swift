//
//  UpdateUserNickname.swift
//  network
//
//  Created by Youjin Lee on 10/14/25.
//  Copyright © 2025 Livith. All rights reserved.
//

// MARK: - 33. 닉네임 수정

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
