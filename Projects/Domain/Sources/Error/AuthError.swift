//
//  AuthError.swift
//  Domain
//
//  Created by 김진웅 on 1/21/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

public enum AuthError: DomainError {
    case noConnection
    case serverError
    case invalidResponse
    case unknown
    case withdrawn
    case recentWithdrawal
    case duplicateNickname
    case nicknameTooLong
    case emptyNickname
    case invalidNickname
    case userNotFound
    case alreadyWithdrawn
    case emptyReason
    case cancelled
    
    // 회원가입 - 장르/아티스트 검증
    case emptyGenreList
    case genreNotFound
    case genreExceedsLimit
    case artistNotFound
    case artistExceedsLimit
    
    public var errorDescription: String? {
        switch self {
        case .noConnection:
            return "네트워크 연결을 확인해주세요."
        case .serverError:
            return "서버에 문제가 발생했습니다. 잠시 후 다시 시도해주세요."
        case .invalidResponse:
            return "데이터를 불러오는데 실패했습니다."
        case .unknown:
            return "알 수 없는 오류가 발생했습니다."
        case .withdrawn:
            return "탈퇴한 회원입니다."
        case .recentWithdrawal:
            return "탈퇴 후 7일이 지나지 않았어요."
        case .duplicateNickname:
            return "이미 존재하는 닉네임이에요."
        case .nicknameTooLong:
            return "닉네임은 10자 이내여야 해요."
        case .emptyNickname:
            return "닉네임을 입력해주세요."
        case .invalidNickname:
            return "닉네임 형식이 올바르지 않아요."
        case .userNotFound:
            return "해당 유저를 찾을 수 없어요."
        case .alreadyWithdrawn:
            return "이미 탈퇴한 회원이에요."
        case .emptyReason:
            return "탈퇴 사유를 선택해주세요."
        case .cancelled:
            return "요청이 취소되었습니다."
        case .emptyGenreList:
            return "최소 1개의 장르는 선택해야 합니다."
        case .genreNotFound:
            return "해당 장르를 찾을 수 없습니다."
        case .genreExceedsLimit:
            return "최대 3개의 장르만 선택할 수 있습니다."
        case .artistNotFound:
            return "해당 아티스트를 찾을 수 없습니다."
        case .artistExceedsLimit:
            return "최대 3개의 아티스트만 선택할 수 있습니다."
        }
    }
    
    public static func from(message: String) -> AuthError {
        switch message {
        case "탈퇴한 회원입니다.":
            return .withdrawn
        case "탈퇴 후 7일이 지나지 않았어요":
            return .recentWithdrawal
        case "이미 존재하는 닉네임이에요.":
            return .duplicateNickname
        case "nickname must be shorter than or equal to 10 characters":
            return .nicknameTooLong
        case "nickname should not be empty":
            return .emptyNickname
        case "해당 유저가 존재하지 않습니다.":
            return .userNotFound
        case "이미 탈퇴한 회원입니다.":
            return .alreadyWithdrawn
        case "reason should not be empty":
            return .emptyReason
        case "최소 1개의 장르는 선택해야 합니다.":
            return .emptyGenreList
        case "해당 장르를 찾을 수 없습니다.":
            return .genreNotFound
        case "최대 3개의 장르만 선택할 수 있습니다.":
            return .genreExceedsLimit
        case "해당 아티스를 찾을 수 없습니다.":
            return .artistNotFound
        case "최대 3개의 아티스트만 선택할 수 있습니다.":
            return .artistExceedsLimit
        default:
            return .unknown
        }
    }
}

