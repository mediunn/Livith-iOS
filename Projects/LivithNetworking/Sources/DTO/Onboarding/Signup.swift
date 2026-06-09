//
//  Signup.swift
//  LivithNetworking
//
//  Created by 김진웅 on 5/27/26.
//  Copyright © 2026 Livith. All rights reserved.
//

// MARK: - 30. 회원가입

import Foundation

public extension DTO.Request {
    struct Signup: Encodable {
        public let nickname: String
        public let preferredArtistIDList: [Int]
        public let preferredGenreIDList: [Int]
        public let email: String?
        public let provider: String
        public let providerID: String
        public let marketingConsent: Bool

        public init(
            nickname: String,
            preferredArtistIDList: [Int],
            preferredGenreIDList: [Int],
            email: String?,
            provider: String,
            providerID: String,
            marketingConsent: Bool
        ) {
            self.nickname = nickname
            self.preferredArtistIDList = preferredArtistIDList
            self.preferredGenreIDList = preferredGenreIDList
            self.email = email
            self.provider = provider
            self.providerID = providerID
            self.marketingConsent = marketingConsent
        }

        enum CodingKeys: String, CodingKey {
            case preferredArtistIDList = "preferredArtistIds"
            case preferredGenreIDList = "preferredGenreIds"
            case nickname, marketingConsent, provider, email
            case providerID = "providerId"
        }
    }
}

public extension DTO.Response {
    struct Signup: Decodable {
        public let accessToken: String
        public let refreshToken: String
        public let user: FetchUserInfo
    }
}
