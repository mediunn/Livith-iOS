//
//  CreateConcertComment.swift
//  LivithNetworking
//
//  Created by 김진웅 on 5/27/26.
//  Copyright © 2026 Livith. All rights reserved.
//

// MARK: - 23. 특정 콘서트 댓글 작성

import Foundation

public extension DTO.Request {
    struct CreateConcertComment: Encodable {
        public let content: String

        public init(content: String) {
            self.content = content
        }
    }
}

public extension DTO.Response {
    struct CreateConcertComment: Decodable {
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
}
