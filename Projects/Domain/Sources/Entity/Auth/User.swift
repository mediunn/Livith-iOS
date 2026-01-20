//
//  User.swift
//  Domain
//
//  Created by 김진웅 on 1/21/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

public struct User: Codable, Identifiable {
    public let id: Int
    public var interestConcertID: Int?
    public let provider: String
    public let providerID: String
    public let email: String?
    public let nickname: String
    public let marketingConsent: Bool

    public init(
        id: Int,
        interestConcertID: Int? = nil,
        provider: String,
        providerID: String,
        email: String?,
        nickname: String,
        marketingConsent: Bool
    ) {
        self.id = id
        self.interestConcertID = interestConcertID
        self.provider = provider
        self.providerID = providerID
        self.email = email
        self.nickname = nickname
        self.marketingConsent = marketingConsent
    }

    enum CodingKeys: String, CodingKey {
        case id
        case interestConcertID = "interestConcertId"
        case providerID = "providerId"
        case provider, email, nickname, marketingConsent
    }
}
