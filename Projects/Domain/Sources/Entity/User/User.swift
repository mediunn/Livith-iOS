//
//  User.swift
//  Domain
//
//  Created by 김진웅 on 1/21/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

public struct User: Identifiable, Hashable, Codable {
    public let id: Int
    public var interestConcertID: Int?
    public let provider: String
    public let providerID: String
    public let email: String?
    public let nickname: String
    public let authority: UserAuthority

    public init(
        id: Int,
        interestConcertID: Int? = nil,
        provider: String,
        providerID: String,
        email: String?,
        nickname: String,
        authority: UserAuthority
    ) {
        self.id = id
        self.interestConcertID = interestConcertID
        self.provider = provider
        self.providerID = providerID
        self.email = email
        self.nickname = nickname
        self.authority = authority
    }

    enum CodingKeys: String, CodingKey {
        case id
        case interestConcertID = "interestConcertId"
        case provider
        case providerID = "providerId"
        case email
        case nickname
        case authority
    }
}
