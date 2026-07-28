//
//  FetchHomeSectionList.swift
//  LivithNetworking
//
//  Created by 김진웅 on 5/27/26.
//  Copyright © 2026 Livith. All rights reserved.
//

// MARK: - 5. 홈 화면 섹션 목록 조회

import Foundation

public extension DTO.Response {
    typealias FetchHomeSectionList = [HomeSection]

    struct HomeSection: Decodable {
        public let id: Int
        public let sectionTitle: String
        public let concerts: [Concert]
    }
}

public extension DTO.Response.HomeSection {
    struct Concert: Decodable {
        public let id: Int
        public let code: String
        public let title: String
        public let startDate: String
        public let endDate: String
        public let status: String
        public let posterURL: String
        public let artist: String
        public let createdAt: String
        public let updatedAt: String
        public let artistID: Int
        public let ticketSite: String?
        public let ticketURL: String?
        public let venue: String
        public let introduction: String
        public let label: String?
        public let sortedIndex: Int
        public let daysLeft: Int

        enum CodingKeys: String, CodingKey {
            case id, code, title, startDate, endDate, status
            case posterURL = "poster"
            case artist, createdAt, updatedAt
            case artistID = "artistId"
            case ticketSite
            case ticketURL = "ticketUrl"
            case venue, introduction, label, sortedIndex, daysLeft
        }
    }
}
