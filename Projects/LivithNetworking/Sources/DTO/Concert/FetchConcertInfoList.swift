//
//  FetchConcertInfoList.swift
//  LivithNetworking
//
//  Created by 김진웅 on 5/27/26.
//  Copyright © 2026 Livith. All rights reserved.
//

// MARK: - 13. 특정 콘서트 필수 정보 목록 조회

import Foundation

public extension DTO.Response {
    typealias FetchConcertInfoList = [ConcertInfoItem]

    struct ConcertInfoItem: Decodable {
        public let id: Int
        public let category: String
        public let content: String
        public let imageURL: String?

        enum CodingKeys: String, CodingKey {
            case id, category, content
            case imageURL = "imgUrl"
        }
    }
}
