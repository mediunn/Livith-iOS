//
//  FetchRecommendedConcertList.swift
//  LivithNetwork
//
//  Created by 김진웅 on 2/5/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

// MARK: - 41. 취향 반영한 콘서트 추천

public extension DTO.Response {
    typealias FetchRecommendedConcertList = [DTO.Response.RecommendedConcert]

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
            case id
            case code
            case title
            case startDate
            case endDate
            case status
            case poster
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
