//
//  FetchConcertCultureList.swift
//  network
//
//  Created by Youjin Lee on 10/14/25.
//  Copyright © 2025 Livith. All rights reserved.
//

// MARK: - 12. 특정 콘서트 문화 목록 조회

import Foundation

public extension DTO.Response {
    typealias FetchConcertCultureList = [ConcertCulture]

    struct ConcertCulture: Decodable {
        public let id: Int
        public let concertID: Int
        public let content: String
        public let title: String

        enum CodingKeys: String, CodingKey {
            case id
            case concertID = "concertId"
            case content
            case title
        }
    }
}
