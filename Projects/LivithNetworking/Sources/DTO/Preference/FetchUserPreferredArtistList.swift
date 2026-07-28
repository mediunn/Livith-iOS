//
//  FetchUserPreferredArtistList.swift
//  LivithNetworking
//
//  Created by 김진웅 on 5/27/26.
//  Copyright © 2026 Livith. All rights reserved.
//

// MARK: - 38. 유저 취향 아티스트 조회

import Foundation

public extension DTO.Response {
    typealias FetchUserPreferredArtistList = [UserPreferredArtist]

    struct UserPreferredArtist: Decodable {
        public let id: Int
        public let userID: Int
        public let genreID: Int
        public let name: String
        public let imageURLString: String?

        enum CodingKeys: String, CodingKey {
            case id
            case userID = "userId"
            case genreID = "genreId"
            case name
            case imageURLString = "imgUrl"
        }
    }
}
