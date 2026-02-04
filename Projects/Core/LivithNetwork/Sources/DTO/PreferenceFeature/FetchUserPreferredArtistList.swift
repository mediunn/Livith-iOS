//
//  FetchUserPreferredArtistList.swift
//  LivithNetwork
//
//  Created by 김진웅 on 2/4/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

// MARK: - 38. 유저 취향 아티스트 조회

public extension DTO.Response {
    typealias FetchUserPreferredArtistList = [UserPreferredArtist]
    
    struct UserPreferredArtist: Decodable {
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
