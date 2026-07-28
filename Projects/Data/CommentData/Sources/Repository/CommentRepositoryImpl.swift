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
    private let networkClient: NetworkClient
    private let mapper: CommentMapper = .init()
    private let errorMapper: CommentErrorMapper = .init()
    
    init(networkClient: NetworkClient) {
        self.networkClient = networkClient
    }
    
    func fetchConcertComments(
        concertID: Int,
        cursor: (createdAt: String, id: Int)?,
        size: Int?
    ) async throws(CommentError) -> (comments: [ConcertComment], cursor: (createdAt: String, id: Int)?, totalCount: Int) {
        do {
            let response: DTO.Response.FetchConcertCommentList = try await networkClient.request(
                CommentAPI.fetchConcertComments(concertID: concertID, cursor: cursor, size: size)
            )
            return mapper.toDomain(from: response)
        } catch {
            throw errorMapper.mapToCommentError(error)
        }
    }
    
    func createComment(concertID: Int, content: String) async throws(CommentError) -> ConcertComment {
        do {
            let response: DTO.Response.CreateConcertComment = try await networkClient.request(
                CommentAPI.createComment(concertID: concertID, content: content)
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
            try await networkClient.request(
                CommentAPI.deleteComment(commentID: commentID)
            )
        } catch {
            throw errorMapper.mapToCommentError(error)
        }
    }
    
    func reportComment(commentID: Int, content: String?) async throws(CommentError) {
        do {
            let _: DTO.Response.CreateCommentReport = try await networkClient.request(
                CommentAPI.reportComment(commentID: commentID, content: content)
            )
        } catch {
            throw errorMapper.mapToCommentError(error)
        }
    }
}
