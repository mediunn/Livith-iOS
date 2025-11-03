//
//  FetchConcertKeyInfoList.swift
//  network
//
//  Created by Youjin Lee on 10/14/25.
//  Copyright © 2025 Livith. All rights reserved.
//

// MARK: - 13. 특정 콘서트 필수 정보 목록 조회

import Foundation

public extension DTO.Response {
    typealias FetchConcertKeyInfoList = [ConcertKeyInfo]

    struct ConcertKeyInfo: Decodable {
        public let id: Int
        public let category: String
        public let content: String
        public let imageURL: String?

        enum CodingKeys: String, CodingKey {
            case id
            case category
            case content
            case imageURL = "imgUrl"
        }
    }
}
