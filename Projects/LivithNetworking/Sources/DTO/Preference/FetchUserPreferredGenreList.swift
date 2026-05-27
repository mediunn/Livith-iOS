//
//  FetchUserPreferredGenreList.swift
//  LivithNetworking
//
//  Created by 김진웅 on 5/27/26.
//  Copyright © 2026 Livith. All rights reserved.
//

// MARK: - 37. 유저 취향 장르 조회

import Foundation

public extension DTO.Response {
    typealias FetchUserPreferredGenreList = [UserPreferredGenre]

    struct UserPreferredGenre: Decodable {
        public let id: Int
        public let userID: Int
        public let name: String
        public let imageURLString: String?

        enum CodingKeys: String, CodingKey {
            case id
            case userID = "userId"
            case name
            case imageURLString = "imgUrl"
        }
    }
}
