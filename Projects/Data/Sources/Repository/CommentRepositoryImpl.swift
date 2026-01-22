//
//  CommentRepositoryImpl.swift
//  Data
//
//  Created by 김진웅 on 1/21/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

import Domain
import LivithNetwork

struct CommentRepositoryImpl: CommentRepository {
    private let commentService: CommentService
    private let mapper: CommentMapper = .init()
    private let errorMapper: CommentErrorMapper = .init()
    
    func fetchConcertComments(
        concertID: Int,
        cursor: (createdAt: String, id: Int)?,
        size: Int?
    ) async throws(CommentError) -> (comments: [ConcertComment], cursor: (createdAt: String, id: Int)?, totalCount: Int) {
        do {
            let response: DTO.Response.FetchConcertCommentList = try await commentService.request(
                .fetchConcertCommentList(concertID: concertID, cursor: cursor, size: size)
            )
            return mapper.toDomain(from: response)
        } catch {
            throw errorMapper.mapToCommentError(error)
        }
    }
    
    func createComment(concertID: Int, content: String) async throws(CommentError) -> ConcertComment {
        do {
            let response: DTO.Response.CreateConcertComment = try await commentService.request(
                .createComment(concertID: concertID, content: content)
            )
            guard let comment = mapper.toDomain(from: response) else {
                throw CommentError.invalidResponse
            }
            return comment
        } catch {
            throw errorMapper.mapToCommentError(error)
        }
    }
    
    func deleteComment(commentID: Int) async throws(CommentError) {
        do {
            let _: DTO.Response.EmptyResponse = try await commentService.request(
                .deleteComment(commentID: commentID)
            )
        } catch {
            throw errorMapper.mapToCommentError(error)
        }
    }
    
    func reportComment(commentID: Int, content: String?) async throws(CommentError) {
        do {
            let _: DTO.Response.CreateCommentReport = try await commentService.request(
                .reportComment(commentID: commentID, content: content)
            )
        } catch {
            throw errorMapper.mapToCommentError(error)
        }
    }
}
