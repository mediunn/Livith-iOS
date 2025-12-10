//
//  FetchConcertMainSetlist.swift
//  network
//
//  Created by Youjin Lee on 10/14/25.
//  Copyright © 2025 Livith. All rights reserved.
//

// MARK: - 3. 특정 콘서트의 대표 셋리스트 조회

import Foundation

public extension DTO.Response {
    struct FetchConcertMainSetlist: Decodable {
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
            case id
            case title
            case imageURL = "imgUrl"
            case type
            case startDate
            case endDate
            case status
            case venue
            case artist
        }
    }
}
