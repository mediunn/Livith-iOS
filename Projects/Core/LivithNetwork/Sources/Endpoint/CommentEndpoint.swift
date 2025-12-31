//
//  CommentEndpoint.swift
//  LivithNetwork
//
//  Created by Youjin Lee on 12/25/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import Foundation

public typealias CommentService = NetworkService<CommentEndpoint>

public enum CommentEndpoint {
    case fetchConcertCommentList(concertID: Int, cursor: (createdAt: String, id: Int)?, size: Int?)
    case createComment(concertID: Int, content: String)
    case deleteComment(commentID: Int)
    case reportComment(commentID: Int, content: String?)
}

extension CommentEndpoint: NetworkEndpoint {
    public var path: String? {
        switch self {
        case .fetchConcertCommentList(let concertID, _, _):
            return "/api/v4/concerts/\(concertID)/comments"
        case .createComment(let concertID, _):
            return "/api/v4/concerts/\(concertID)/comments"
        case .deleteComment(let commentID):
            return "/api/v4/comments/\(commentID)"
        case .reportComment(let commentID, _):
            return "/api/v4/comments/\(commentID)/report"
        }
    }

    public var query: [String: Any]? {
        switch self {
        case .fetchConcertCommentList(_, let cursor, let size):
            var params: [String: Any] = [:]

            if let cursor = cursor {
                let cursorDict: [String: Any] = [
                    "createdAt": cursor.createdAt,
                    "id": cursor.id
                ]
                if let jsonData = try? JSONSerialization.data(withJSONObject: cursorDict),
                   let jsonString = String(data: jsonData, encoding: .utf8) {
                    params["cursor"] = jsonString
                }
            }

            if let size = size {
                params["size"] = size
            }

            return params.isEmpty ? nil : params
        default:
            return nil
        }
    }

    public var method: HTTPMethod {
        switch self {
        case .fetchConcertCommentList:
            return .get
        case .createComment, .reportComment:
            return .post
        case .deleteComment:
            return .delete
        }
    }

    public var headers: HTTPHeaders? {
        return nil
    }

    public var body: Encodable? {
        switch self {
        case .fetchConcertCommentList, .deleteComment:
            return nil
        case .createComment(_, let content):
            return DTO.Request.CreateConcertComment(content: content)
        case .reportComment(_, let content):
            return DTO.Request.CreateCommentReport(content: content)
        }
    }

    public var requiresInterceptor: Bool {
        return true
    }
}
