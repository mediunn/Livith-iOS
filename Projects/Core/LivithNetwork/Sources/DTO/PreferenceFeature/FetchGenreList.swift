//
//  FetchGenreList.swift
//  LivithNetwork
//
//  Created by 김진웅 on 2/4/2026.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

// MARK: - 39. 장르 목록 조회

public extension DTO.Response {
    typealias FetchGenreList = [FetchGenre]
    
    struct FetchGenre: Decodable {
        public let id: Int
        public let name: String
        public let imageURLString: String
        
        public enum CodingKeys: String, CodingKey {
            case id
            case name
            case imageURLString = "imgUrl"
        }
    }
}
