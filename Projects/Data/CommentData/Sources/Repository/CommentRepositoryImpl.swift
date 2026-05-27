//
//  CommentRepositoryImpl.swift
//  Data
//
//  Created by 김진웅 on 1/21/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

import Domain
import LivithNetworking

struct CommentRepositoryImpl: CommentRepository {
    private let commentService: any CommentService
    private let mapper: CommentMapper = .init()
    private let errorMapper: CommentErrorMapper = .init()
    
    init(commentService: any CommentService) {
        self.commentService = commentService
    }
    
    func fetchConcertComments(
        concertID: Int,
        cursor: (createdAt: String, id: Int)?,
        size: Int?
    ) async throws(CommentError) -> (comments: [ConcertComment], cursor: (createdAt: String, id: Int)?, totalCount: Int) {
        do {
            let response = try await commentService.fetchConcertComments(concertID: concertID, cursor: cursor, size: size)
            return mapper.toDomain(from: response)
        } catch {
            throw errorMapper.mapToCommentError(error)
        }
    }
    
    func createComment(concertID: Int, content: String) async throws(CommentError) -> ConcertComment {
        do {
            let response = try await commentService.createComment(concertID: concertID, content: content)
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
            try await commentService.deleteComment(commentID: commentID)
        } catch {
            throw errorMapper.mapToCommentError(error)
        }
    }
    
    func reportComment(commentID: Int, content: String?) async throws(CommentError) {
        do {
            _ = try await commentService.reportComment(commentID: commentID, content: content)
        } catch {
            throw errorMapper.mapToCommentError(error)
        }
    }
}
