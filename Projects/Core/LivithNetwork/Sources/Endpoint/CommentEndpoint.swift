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
    case fetchConcertComments(concertID: Int, cursor: String?, size: Int?)
    case createComment(concertID: Int, content: String)
    case deleteComment(commentID: Int)
    case reportComment(commentID: Int, content: String?)
}

extension CommentEndpoint: NetworkEndpoint {
    public var path: String? {
        switch self {
        case .fetchConcertComments(let concertID, _, _):
            return "/api/v4/concerts/\(concertID)/comments"
        case .createComment(let concertID, _):
            return "/api/v4/concerts/\(concertID)/comment"
        case .deleteComment(let commentID):
            return "/api/v4/comments/\(commentID)"
        case .reportComment(let commentID, _):
            return "/api/v4/comments/\(commentID)/report"
        }
    }

    public var query: [String: Any]? {
        switch self {
        case .fetchConcertComments(_, let cursor, let size):
            let params: [String: Any?] = [
                "cursor": cursor,
                "size": size
            ]
            return params.compactMapValues { $0 }
        case .createComment, .deleteComment, .reportComment:
            return nil
        }
    }

    public var method: HTTPMethod {
        switch self {
        case .fetchConcertComments:
            return .get
        case .createComment, .reportComment:
            return .post
        case .deleteComment:
            return .delete
        }
    }

    public var headers: HTTPHeaders? {
        switch self {
        case .fetchConcertComments, .createComment, .deleteComment, .reportComment:
            return nil
        }
    }

    public var body: Encodable? {
        switch self {
        case .fetchConcertComments, .deleteComment:
            return nil
        case .createComment(_, let content):
            return DTO.Request.CreateConcertComment(content: content)
        case .reportComment(_, let content):
            return DTO.Request.CreateCommentReport(content: content)
        }
    }

    public var requiresInterceptor: Bool {
        switch self {
        case .fetchConcertComments, .createComment, .deleteComment, .reportComment:
            return true
        }
    }
}
