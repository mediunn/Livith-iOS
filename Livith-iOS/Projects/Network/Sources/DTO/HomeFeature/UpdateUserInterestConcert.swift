//
//  UpdateUserInterestConcert.swift
//  network
//
//  Created by Youjin Lee on 10/14/25.
//  Copyright © 2025 Livith. All rights reserved.
//

// MARK: - 7. 유저의 관심 콘서트 설정

import Foundation

public extension DTO.Request {
    struct UpdateUserInterestConcert: Encodable {
        public let concertID: String

        enum CodingKeys: String, CodingKey {
            case concertID = "concertId"
        }
    }
}

public extension DTO.Response {
    struct UpdateUserInterestConcert: Decodable {
        public let id: Int
        public let code: String
        public let title: String
        public let startDate: String
        public let endDate: String
        public let status: String
        public let posterURL: String
        public let artist: String
        public let ticketSite: String
        public let ticketURL: String
        public let venue: String
        public let introduction: String
        public let label: String

        enum CodingKeys: String, CodingKey {
            case id
            case code
            case title
            case startDate
            case endDate
            case status
            case posterURL = "poster"
            case artist
            case ticketSite
            case ticketURL = "ticketUrl"
            case venue
            case introduction
            case label
        }
    }
}
