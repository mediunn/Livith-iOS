//
//  UserError.swift
//  Domain
//
//  Created by 김진웅 on 1/21/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

public enum UserError: DomainError {
    case noConnection
    case serverError
    case invalidResponse
    case unknown
    case userNotFound
    case duplicateNickname
    case nicknameTooLong
    case withdrawn
    case emptyNickname
    case concertNotFound
    case invalidConcertID
    case cancelled
    
    public var errorDescription: String? {
        switch self {
        case .noConnection:
            return "네트워크 연결을 확인해주세요."
        case .serverError:
            return "서버 오류가 발생했어요."
        case .invalidResponse:
            return "데이터를 불러오는데 실패했어요."
        case .unknown:
            return "알 수 없는 오류가 발생했어요."
        case .userNotFound:
            return "해당 유저를 찾을 수 없어요."
        case .duplicateNickname:
            return "이미 사용 중인 닉네임이에요."
        case .nicknameTooLong:
            return "닉네임은 10자 이내여야 해요."
        case .withdrawn:
            return "탈퇴한 회원이에요."
        case .emptyNickname:
            return "닉네임을 입력해주세요."
        case .concertNotFound:
            return "콘서트를 찾을 수 없어요."
        case .invalidConcertID:
            return "잘못된 콘서트 정보에요."
        case .cancelled:
            return "요청이 취소되었습니다."
        }
    }
    
    public static func from(message: String) -> UserError {
        switch message {
        case "해당 유저가 존재하지 않습니다.":
            return .userNotFound
        case "이미 존재하는 닉네임이에요.":
            return .duplicateNickname
        case "nickname must be shorter than or equal to 10 characters":
            return .nicknameTooLong
        case "탈퇴한 회원입니다.":
            return .withdrawn
        case "nickname should not be empty":
            return .emptyNickname
        case "해당 콘서트가 존재하지 않습니다.":
            return .concertNotFound
        case "concertId must be an integer number":
            return .invalidConcertID
        default:
            return .unknown
        }
    }
}
