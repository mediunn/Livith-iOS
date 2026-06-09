//
//  UpdateUserInterestConcert.swift
//  LivithNetworking
//
//  Created by 김진웅 on 5/27/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

public extension DTO.Request {
    struct UpdateUserInterestConcert: Encodable {
        public let concertID: Int

        public init(concertID: Int) {
            self.concertID = concertID
        }

        enum CodingKeys: String, CodingKey {
            case concertID = "concertId"
        }
    }
}

public extension DTO.Response {
    struct UpdateUserInterestConcert: Codable {
        public let id: Int
        public let code: String
        public let title: String
        public let startDate: String
        public let endDate: String
        public let status: String
        public let posterURL: String
        public let artist: String
        public let ticketSite: String?
        public let ticketURL: String?
        public let venue: String
        public let introduction: String
        public let label: String?

        enum CodingKeys: String, CodingKey {
            case id, code, title, startDate, endDate, status
            case posterURL = "poster"
            case artist, ticketSite
            case ticketURL = "ticketUrl"
            case venue, introduction, label
        }
    }
}
