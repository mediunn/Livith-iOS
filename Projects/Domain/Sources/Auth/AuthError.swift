//
//  AuthError.swift
//  Domain
//
//  Created by 김진웅 on 1/21/26.
//  Copyright © 2026 Livith. All rights reserved.
//

public enum AuthError: Error {
    case noConnection
    case serverError
    case invalidResponse
    case unknown
    case withdrawn
    case recentlyWithdrawn
    case duplicateNickname
    case nicknameTooLong
    case emptyNickname
    case invalidNickname
    case nicknameNotConfirmed
    case requiredTermsNotAgreed
    case userNotFound
    case emptyReason
    case cancelled

    // 회원가입 - 장르/아티스트 검증
    case emptyGenreList
    case genreNotFound
    case genreExceedsLimit
    case artistNotFound
    case artistExceedsLimit
}
