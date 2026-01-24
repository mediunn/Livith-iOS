//
//  CommentMapper.swift
//  Data
//
//  Created by 김진웅 on 1/21/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

import Domain
import LivithNetwork
import LivithFoundation

struct CommentMapper {
    func toDomain(from response: DTO.Response.FetchConcertCommentList) -> (comments: [ConcertComment], cursor: (createdAt: String, id: Int)?, totalCount: Int) {
        let comments = response.data.compactMap { dto -> ConcertComment? in
            guard let createdAt = DateFormatterService.date(from: dto.createdAt, type: .iso8601) else {
                return nil
            }
            return ConcertComment(
                id: dto.id,
                userID: dto.userID,
                writer: dto.nickname,
                content: dto.content,
                createdAt: createdAt
            )
        }
        
        var cursor: (createdAt: String, id: Int)?
        if let responseCursor = response.cursor {
            cursor = (createdAt: responseCursor.createdAt, id: responseCursor.id)
        }
        
        return (comments, cursor, response.totalCount)
    }
    
    func toDomain(from response: DTO.Response.CreateConcertComment) -> ConcertComment? {
        guard let createdAt = DateFormatterService.date(from: response.createdAt, type: .iso8601) else {
            return nil
        }

        return ConcertComment(
            id: response.id,
            userID: response.userID,
            writer: response.nickname,
            content: response.content,
            createdAt: createdAt
        )
    }
}
