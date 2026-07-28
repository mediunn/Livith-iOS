//
//  CommentAPI.swift
//  LivithNetworking
//
//  Created by 김진웅 on 5/27/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

public enum CommentAPI {
    public static func fetchConcertComments(
        concertID: Int,
        cursor: (createdAt: String, id: Int)?,
        size: Int?
    ) -> NetworkEndpoint {
        var queryItems: [URLQueryItem] = []

        if let cursor = cursor {
            let cursorDict: [String: Any] = [
                "createdAt": cursor.createdAt,
                "id": cursor.id
            ]
            if let jsonData = try? JSONSerialization.data(withJSONObject: cursorDict),
               let jsonString = String(data: jsonData, encoding: .utf8) {
                queryItems.append(URLQueryItem(name: "cursor", value: jsonString))
            }
        }

        if let size = size {
            queryItems.append(URLQueryItem(name: "size", value: String(size)))
        }

        return NetworkEndpoint(
            path: "/concerts/\(concertID)/comments",
            method: .get,
            task: queryItems.isEmpty ? .plain : .query(queryItems),
            authentication: .required
        )
    }

    public static func createComment(concertID: Int, content: String) -> NetworkEndpoint {
        NetworkEndpoint(
            path: "/concerts/\(concertID)/comments",
            method: .post,
            task: .body(DTO.Request.CreateConcertComment(content: content)),
            authentication: .required
        )
    }

    public static func deleteComment(commentID: Int) -> NetworkEndpoint {
        NetworkEndpoint(
            path: "/comments/\(commentID)",
            method: .delete,
            task: .plain,
            authentication: .required
        )
    }

    public static func reportComment(commentID: Int, content: String?) -> NetworkEndpoint {
        NetworkEndpoint(
            path: "/comments/\(commentID)/report",
            method: .post,
            task: .body(DTO.Request.CreateCommentReport(content: content)),
            authentication: .required
        )
    }
}
