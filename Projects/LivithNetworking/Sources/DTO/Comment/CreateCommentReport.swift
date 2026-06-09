//
//  CreateCommentReport.swift
//  LivithNetworking
//
//  Created by 김진웅 on 5/27/26.
//  Copyright © 2026 Livith. All rights reserved.
//

// MARK: - 25. 특정 댓글 신고

import Foundation

public extension DTO.Request {
    struct CreateCommentReport: Encodable {
        public let content: String?

        public init(content: String?) {
            self.content = content
        }
    }
}

public extension DTO.Response {
    struct CreateCommentReport: Decodable {
        public let id: Int
        public let commentID: Int
        public let commentUserID: Int
        public let commentContent: String
        public let reportReason: String?
        public let createdAt: String

        enum CodingKeys: String, CodingKey {
            case id
            case commentID = "commentId"
            case commentUserID = "commentUserId"
            case commentContent
            case reportReason
            case createdAt
        }
    }
}
