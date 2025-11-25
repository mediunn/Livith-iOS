//
//  FetchFilterSearchResult.swift
//  network
//
//  Created by Youjin Lee on 10/14/25.
//  Copyright © 2025 Livith. All rights reserved.
//

// MARK: - 11. 필터에 따른 검색 결과 콘서트 목록 조회

import Foundation

import LivithNetwork

public extension DTO.Response {
    struct FetchFilterSearchResult: Decodable {
        public let data: [FilteredConcert]
        public let cursor: Cursor?
        public let totalCount: Int

        public struct FilteredConcert: Decodable {
            public let id: Int
            public let code: String
            public let title: String
            public let startDate: String
            public let endDate: String
            public let status: String
            public let posterURL: String
            public let artist: String
            public let daysLeft: Int
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
                case daysLeft
                case ticketSite
                case ticketURL = "ticketUrl"
                case venue
                case introduction
                case label
            }
        }

        public struct Cursor: Decodable {
            public let value: String
            public let id: Int
        }
    }
}
