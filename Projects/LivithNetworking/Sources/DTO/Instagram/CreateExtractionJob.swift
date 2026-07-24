//
//  CreateExtractionJob.swift
//  LivithNetworking
//
//  Created by youz2me on 7/20/26.
//  Copyright © 2026 Livith. All rights reserved.
//

// MARK: - 48. 인스타 추출 및 콘서트 매칭

import Foundation

public extension DTO.Request {
    struct CreateExtractionJob: Encodable {
        public let instagramUrl: String

        public init(instagramUrl: String) {
            self.instagramUrl = instagramUrl
        }
    }
}

public extension DTO.Response {
    struct CreateExtractionJob: Decodable {
        public let result: String
        public let concerts: [MatchedConcert]

        public struct MatchedConcert: Decodable {
            public let id: Int
            public let code: String?
            public let title: String?
            public let startDate: String?
            public let endDate: String?
            public let status: String
            public let poster: String?
            public let artist: String
            public let daysLeft: Int?
            public let ticketSite: String?
            public let ticketURL: String?
            public let venue: String?
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
}
