//
//  CreateUser.swift
//  LoginData
//
//  Created by Youjin Lee on 10/14/25.
//  Copyright © 2025 Livith. All rights reserved.
//

// MARK: - 30. 회원가입

import Foundation

import LivithNetwork

public extension DTO.Request {
    struct CreateUser: Encodable {
        let nickname: String
        let marketingConsent: Bool
        let providerID: String
        let provider: String
        let email: String?

        enum CodingKeys: String, CodingKey {
            case nickname, marketingConsent, provider, email
            case providerID = "providerId"
        }
    }
}

public extension DTO.Response {
    struct CreateUser: Decodable {
        let user: User
        let accessToken: String
        let refreshToken: String?
        
        struct User: Decodable {
            let id: Int
            let interestConcertID: Int?
            let provider: String
            let providerID: String
            let email: String?
            let nickname: String
            let marketingConsent: Bool

            enum CodingKeys: String, CodingKey {
                case id, provider, email, nickname, marketingConsent
                case interestConcertID = "interestConcertId"
                case providerID = "providerId"
            }
        }
    }
}
