//
//  FetchGenreList.swift
//  LivithNetworking
//
//  Created by 김진웅 on 5/27/26.
//  Copyright © 2026 Livith. All rights reserved.
//

// MARK: - 39. 장르 목록 조회

import Foundation

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
