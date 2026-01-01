//
//  CommentRepositoryImpl.swift
//  ConcertData
//
//  Created by Youjin Lee on 12/25/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import Foundation

import ConcertDomain
import LivithNetwork

public struct CommentRepositoryImpl {
    private let service: CommentService
    private let entityMapper: ConcertMapper = .init()
    private let errorMapper: ConcertErrorMapper = .init()

    public init(service: CommentService = .init()) {
        self.service = service
    }
}

extension CommentRepositoryImpl: CommentRepository {
    public func fetchConcertComments(
        concertID: Int,
        cursor: (createdAt: String, id: Int)?,
        size: Int?
    ) async throws(ConcertError) -> (comments: [ConcertComment], cursor: (createdAt: String, id: Int)?, totalCount: Int) {
        do {
            let response: DTO.Response.FetchConcertCommentList = try await service.request(
                .fetchConcertCommentList(concertID: concertID, cursor: cursor, size: size)
            )
            return entityMapper.toDomain(from: response)
        } catch {
            throw errorMapper.mapToConcertError(error)
        }
    }

    public func createComment(concertID: Int, content: String) async throws(ConcertError) -> ConcertComment {
        do {
            let response: DTO.Response.CreateConcertComment = try await service.request(
                .createComment(concertID: concertID, content: content)
            )
            return entityMapper.toDomain(from: response)
        } catch {
            throw errorMapper.mapToConcertError(error)
        }
    }

    public func deleteComment(commentID: Int) async throws(ConcertError) {
        do {
            let _: DTO.Response.EmptyResponse = try await service.request(
                .deleteComment(commentID: commentID)
            )
        } catch {
            throw errorMapper.mapToConcertError(error)
        }
    }

    public func reportComment(commentID: Int, content: String?) async throws(ConcertError) {
        do {
            let _: DTO.Response.CreateCommentReport = try await service.request(
                .reportComment(commentID: commentID, content: content)
            )
        } catch {
            throw errorMapper.mapToConcertError(error)
        }
    }
}
