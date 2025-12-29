//
//  FetchConcertMerchandiseList.swift
//  network
//
//  Created by Youjin Lee on 10/14/25.
//  Copyright © 2025 Livith. All rights reserved.
//

// MARK: - 14. 특정 콘서트 MD 목록 조회

import Foundation

public extension DTO.Response {
    typealias FetchConcertMerchandiseList = [ConcertMerchandise]

    struct ConcertMerchandise: Decodable {
        public let id: Int
        public let name: String
        public let price: String?
        public let imageURL: String?

        enum CodingKeys: String, CodingKey {
            case id
            case name
            case price
            case imageURL = "imgUrl"
        }
    }
}
