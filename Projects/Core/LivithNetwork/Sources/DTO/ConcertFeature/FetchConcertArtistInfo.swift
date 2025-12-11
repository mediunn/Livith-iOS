//
//  FetchConcertArtistInfo.swift
//  network
//
//  Created by Youjin Lee on 10/14/25.
//  Copyright © 2025 Livith. All rights reserved.
//

// MARK: - 16. 특정 콘서트 아티스트 조회

import Foundation

public extension DTO.Response {
    struct FetchConcertArtistInfo: Decodable {
        public let id: Int
        public let artist: String
        public let debutDate: String
        public let category: String
        public let detail: String
        public let instagramURL: String?
        public let keywords: [String]
        public let imageURL: String?

        enum CodingKeys: String, CodingKey {
            case id
            case artist
            case debutDate
            case category
            case detail
            case instagramURL = "instagramUrl"
            case keywords
            case imageURL = "imgUrl"
        }
    }
}
