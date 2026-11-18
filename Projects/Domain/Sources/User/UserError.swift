//
//  UserError.swift
//  Domain
//
//  Created by 김진웅 on 1/21/26.
//  Copyright © 2026 Livith. All rights reserved.
//

public enum UserError: Error {
    case noConnection
    case serverError
    case invalidResponse
    case invalidRequest
    case unknown
    case userNotFound
    case duplicateNickname
    case nicknameTooLong
    case withdrawn
    case emptyNickname
    case concertNotFound
    case invalidConcertID
    case cancelled
}
