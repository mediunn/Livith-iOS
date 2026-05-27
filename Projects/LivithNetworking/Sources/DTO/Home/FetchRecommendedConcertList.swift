//
//  FetchRecommendedConcertList.swift
//  LivithNetworking
//
//  Created by 김진웅 on 5/27/26.
//  Copyright © 2026 Livith. All rights reserved.
//

// MARK: - 41. 취향 반영한 콘서트 추천

import Foundation

public extension DTO.Response {
    typealias FetchRecommendedConcertList = [RecommendedConcert]

    struct RecommendedConcert: Decodable {
        public let id: Int
        public let code: String?
        public let title: String
        public let startDate: String
        public let endDate: String
        public let status: String
        public let poster: String
        public let artist: String
        public let daysLeft: Int
        public let ticketSite: String?
        public let ticketURL: String?
        public let venue: String
        public let introduction: String
        public let label: String?

        enum CodingKeys: String, CodingKey {
            case id, code, title, startDate, endDate, status
            case poster, artist, daysLeft, ticketSite
            case ticketURL = "ticketUrl"
            case venue, introduction, label
        }
    }
}
