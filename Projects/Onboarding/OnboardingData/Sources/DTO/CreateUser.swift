//
//  CreateUser.swift
//  network
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
        let userId: String
        let providerId: String
        let provider: String
        let email: String?
    }
}

public extension DTO.Response {
    struct CreateUser: Decodable {
        let user: User
        let accessToken: String
        let refreshToken: String?
        
        struct User: Decodable {
            let id: Int
            let interestConcertId: Int?
            let provider: String
            let providerId: String
            let email: String?
            let nickname: String
            let marketingConsent: Bool
        }
    }
}
