//
//  CommentRepository.swift
//  ConcertDomain
//
//  Created by Youjin Lee on 12/25/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import Foundation

public protocol CommentRepository {
    func fetchConcertComments(
        concertID: Int,
        cursor: String?,
        size: Int?
    ) async throws(ConcertError) -> (comments: [ConcertComment], cursor: (createdAt: String, id: Int)?, totalCount: Int)

    func createComment(concertID: Int, content: String) async throws(ConcertError) -> ConcertComment
    func deleteComment(commentID: Int) async throws(ConcertError)
    func reportComment(commentID: Int, content: String?) async throws(ConcertError)
}
