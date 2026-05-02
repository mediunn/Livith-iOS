//
//  FetchConcertList.swift
//  LivithNetwork
//
//  Created by 김진웅 on 12/30/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import Foundation

// MARK: - 20. 콘서트 목록 조회

public extension DTO.Response {
    struct FetchConcertList: Decodable {
        public let data: [FilteredConcert]
        public let cursor: Int?

        public struct FilteredConcert: Decodable {
            public let id: Int
            public let code: String?
            public let title: String?
            public let startDate: String?
            public let endDate: String?
            public let status: String
            public let posterURL: String?
            public let artist: String
            public let daysLeft: Int?
            public let ticketSite: String?
            public let ticketURL: String?
            public let venue: String?
            public let introduction: String
            public let label: String?

            enum CodingKeys: String, CodingKey {
                case id
                case code
                case title
                case startDate
                case endDate
                case status
                case posterURL = "poster"
                case artist
                case daysLeft
                case ticketSite
                case ticketURL = "ticketUrl"
                case venue
                case introduction
                case label
            }
        }
    }
}
