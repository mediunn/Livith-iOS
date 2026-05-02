//
//  UpdateUserInterestConcertList.swift
//  LivithNetwork
//
//  Created by 김진웅 on 5/1/26.
//  Copyright © 2026 Livith. All rights reserved.
//

// MARK: - 7. 유저의 관심 콘서트 설정/수정

import Foundation

public extension DTO.Request {
    struct UpdateUserInterestConcertList: Encodable {
        public let concertIDList: [Int]

        public init(concertIDList: [Int]) {
            self.concertIDList = concertIDList
        }

        enum CodingKeys: String, CodingKey {
            case concertIDList = "concertIds"
        }
    }
}

public extension DTO.Response {
    typealias UpdateUserInterestConcertList = [UpdatedUserInterestConcert]

    struct UpdatedUserInterestConcert: Decodable {
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
