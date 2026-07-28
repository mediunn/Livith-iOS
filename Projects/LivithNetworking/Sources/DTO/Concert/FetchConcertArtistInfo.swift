//
//  FetchConcertArtistInfo.swift
//  LivithNetworking
//
//  Created by 김진웅 on 5/27/26.
//  Copyright © 2026 Livith. All rights reserved.
//

// MARK: - 16. 특정 콘서트 아티스트 조회

import Foundation

public extension DTO.Response {
    struct FetchConcertArtistInfo: Decodable {
        public let id: Int
        public let artist: String
        public let debutYear: String
        public let category: String
        public let detail: String
        public let instagramURL: String?
        public let twitterURL: String?
        public let keywords: [String]
        public let imageURL: String?

        enum CodingKeys: String, CodingKey {
            case id
            case artist
            case debutYear = "debutDate"
            case category
            case detail
            case instagramURL = "instagramUrl"
            case twitterURL = "twitterUrl"
            case keywords
            case imageURL = "imgUrl"
        }
    }
}
