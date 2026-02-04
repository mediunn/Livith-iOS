//
//  FetchUserPreferredGenreList.swift
//  LivithNetwork
//
//  Created by 김진웅 on 2/4/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

// MARK: - 37. 유저 취향 장르 조회, 42. 유저 취향 장르 설정/변경

public extension DTO.Response {
    typealias FetchUserPreferredGenreList = [UserPreferredGenre]
    
    struct UserPreferredGenre: Decodable {
        public let id: Int
        public let userId: Int
        public let name: String
        public let imageURLString: String?
        
        enum CodingKeys: String, CodingKey {
            case id
            case userId
            case name
            case imageURLString = "imgUrl"
        }
    }
}
