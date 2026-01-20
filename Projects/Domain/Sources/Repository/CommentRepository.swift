//
//  CommentRepository.swift
//  Domain
//
//  Created by 김진웅 on 1/21/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

public protocol CommentRepository {
    func fetchConcertComments(
        concertID: Int,
        cursor: (createdAt: String, id: Int)?,
        size: Int?
    ) async throws(CommentError) -> (comments: [ConcertComment], cursor: (createdAt: String, id: Int)?, totalCount: Int)
    func createComment(concertID: Int, content: String) async throws(CommentError) -> ConcertComment
    func deleteComment(commentID: Int) async throws(CommentError)
    func reportComment(commentID: Int, content: String?) async throws(CommentError)
}
