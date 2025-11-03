//
//  FetchConcertCommentList.swift
//  network
//
//  Created by Youjin Lee on 10/14/25.
//  Copyright © 2025 Livith. All rights reserved.
//

// MARK: - 22. 특정 콘서트 댓글 목록 조회

import Foundation

public extension DTO.Response {
    struct FetchConcertCommentList: Decodable {
        public let data: [Comment]
        public let cursor: Cursor
        public let totalCount: Int

        public struct Comment: Decodable {
            public let id: Int
            public let userID: Int
            public let nickname: String
            public let concertID: Int
            public let content: String
            public let createdAt: String

            enum CodingKeys: String, CodingKey {
                case id
                case userID = "userId"
                case nickname
                case concertID = "concertId"
                case content
                case createdAt
            }
        }

        public struct Cursor: Decodable {
            public let createdAt: String
            public let id: Int
        }
    }
}
