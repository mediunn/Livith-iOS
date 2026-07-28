//
//  FetchConcertSetlistList.swift
//  LivithNetworking
//
//  Created by 김진웅 on 5/27/26.
//  Copyright © 2026 Livith. All rights reserved.
//

// MARK: - 15. 특정 콘서트 셋리스트 목록 조회

import Foundation

public extension DTO.Response {
    typealias FetchConcertSetlistList = [ConcertSetlist]

    struct ConcertSetlist: Decodable {
        public let id: Int
        public let title: String
        public let imageURL: String?
        public let type: String
        public let startDate: String
        public let endDate: String
        public let status: String?
        public let venue: String
        public let artist: String

        enum CodingKeys: String, CodingKey {
            case id, title
            case imageURL = "imgUrl"
            case type, startDate, endDate, status, venue, artist
        }
    }
}
