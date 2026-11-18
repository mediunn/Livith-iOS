//
//  CommentError.swift
//  Domain
//
//  Created by 김진웅 on 1/21/26.
//  Copyright © 2026 Livith. All rights reserved.
//

public enum CommentError: Error {
    case noConnection
    case serverError
    case invalidResponse
    case unknown
    case concertNotFound
    case invalidID
    case invalidSize
    case invalidCursor
    case emptyContent
    case contentTooLong
    case userNotFound
    case withdrawn
    case commentNotFound
    case forbidden
    case reportReasonTooLong
    case cancelled
}
