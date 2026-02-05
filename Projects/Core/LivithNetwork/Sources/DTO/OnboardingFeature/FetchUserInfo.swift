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
    struct FetchUserInfo: Codable {
        public let id: Int
        public let interestConcertID: Int?
        public let provider: String
        public let providerID: String
        public let email: String?
        public let nickname: String
        public let marketingConsent: Bool
        public let preferredGenreList: [PreferenceInfo]
        public let preferredArtistList: [PreferenceInfo]
        
        enum CodingKeys: String, CodingKey {
            case id
            case interestConcertID = "interestConcertId"
            case providerID = "providerId"
            case provider, email, nickname, marketingConsent
            case preferredGenreList = "preferredGenres"
            case preferredArtistList = "preferredArtists"
        }
    }
}

public extension DTO.Response.FetchUserInfo {
    struct PreferenceInfo: Codable {
        public let id: Int
        public let name: String
    }
}
