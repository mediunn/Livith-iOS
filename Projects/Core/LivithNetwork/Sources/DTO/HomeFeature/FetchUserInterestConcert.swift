//
//  FetchUserInterestConcert.swift
//  network
//
//  Created by Youjin Lee on 10/14/25.
//  Copyright © 2025 Livith. All rights reserved.
//

// MARK: - 6. 유저의 관심 콘서트 조회

import Foundation

public extension DTO.Request {
    struct FetchInterestConcertList: Encodable {
        public let sort: Sort?
        public let size: Int?
        public let cursorDate: String?
        public let cursorID: Int?

        public init(
            sort: Sort? = nil,
            size: Int? = nil,
            cursorDate: String? = nil,
            cursorID: Int? = nil
        ) {
            self.sort = sort
            self.size = size
            self.cursorDate = cursorDate
            self.cursorID = cursorID
        }

        enum CodingKeys: String, CodingKey {
            case sort
            case size
            case cursorDate
            case cursorID = "cursorId"
        }

        public enum Sort: String, Encodable {
            case concert = "CONCERT"
            case ticketing = "TICKETING"
        }
    }
}

public extension DTO.Response {
    struct FetchUserInterestConcert: Codable {
        public let data: [Concert]
        public let cursor: Cursor?

        public struct Concert: Codable {
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
            public let preSaleDate: String?
            public let generalSaleDate: String?

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
                case preSaleDate
                case generalSaleDate
            }
        }

        public struct Cursor: Codable, Equatable {
            public let date: String?
            public let id: Int?
        }
    }
}
