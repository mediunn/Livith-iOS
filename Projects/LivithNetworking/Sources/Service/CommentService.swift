//
//  CommentService.swift
//  LivithNetworking
//
//  Created by 김진웅 on 5/27/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

// MARK: - CommentService

public protocol CommentService: Sendable {
    func fetchConcertComments(
        concertID: Int,
        cursor: (createdAt: String, id: Int)?,
        size: Int?
    ) async throws(NetworkError) -> DTO.Response.FetchConcertCommentList
    func createComment(concertID: Int, content: String) async throws(NetworkError) -> DTO.Response.CreateConcertComment
    func deleteComment(commentID: Int) async throws(NetworkError)
    func reportComment(commentID: Int, content: String?) async throws(NetworkError) -> DTO.Response.CreateCommentReport
}

// MARK: - CommentServiceImpl

struct CommentServiceImpl: CommentService {
    private let networkClient: NetworkClient

    init(networkClient: NetworkClient) {
        self.networkClient = networkClient
    }

    public func fetchConcertComments(
        concertID: Int,
        cursor: (createdAt: String, id: Int)?,
        size: Int?
    ) async throws(NetworkError) -> DTO.Response.FetchConcertCommentList {
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

        return try await networkClient.request(
            NetworkEndpoint(
                path: "/concerts/\(concertID)/comments",
                method: .get,
                task: queryItems.isEmpty ? .plain : .query(queryItems),
                authentication: .required
            )
        )
    }

    public func createComment(concertID: Int, content: String) async throws(NetworkError) -> DTO.Response.CreateConcertComment {
        return try await networkClient.request(
            NetworkEndpoint(
                path: "/concerts/\(concertID)/comments",
                method: .post,
                task: .body(DTO.Request.CreateConcertComment(content: content)),
                authentication: .required
            )
        )
    }

    public func deleteComment(commentID: Int) async throws(NetworkError) {
        try await networkClient.request(
            NetworkEndpoint(
                path: "/comments/\(commentID)",
                method: .delete,
                task: .plain,
                authentication: .required
            )
        )
    }

    public func reportComment(commentID: Int, content: String?) async throws(NetworkError) -> DTO.Response.CreateCommentReport {
        return try await networkClient.request(
            NetworkEndpoint(
                path: "/comments/\(commentID)/report",
                method: .post,
                task: .body(DTO.Request.CreateCommentReport(content: content)),
                authentication: .required
            )
        )
    }
}
