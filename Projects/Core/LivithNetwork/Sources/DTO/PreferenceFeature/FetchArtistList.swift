//
//  FetchArtistList.swift
//  LivithNetwork
//
//  Created by 김진웅 on 2/4/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

public extension DTO.Response {
    struct FetchArtistList: Decodable {
        public let data: [Artist]
        public let cursor: Int?
        public let totalCount: Int?
        
        public struct Artist: Decodable {
            public let id: Int
            public let name: String
            public let genreId: Int
            public let imageURLString: String?
            
            enum CodingKeys: String, CodingKey {
                case id
                case name
                case genreId
                case imageURLString = "imgUrl"
            }
        }
    }
}
