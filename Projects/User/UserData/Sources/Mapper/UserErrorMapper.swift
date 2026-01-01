//
//  UserErrorMapper.swift
//  User
//
//  Created by Youjin Lee on 12/11/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import Foundation

import LivithNetwork
import UserDomain

public struct UserErrorMapper {
    func mapToUserError(_ networkError: NetworkError) -> UserError {
        switch networkError {
        case .badRequest(message: Constant.userNotFound):
            return .userNotFound
        case .badRequest(message: Constant.deletedUser):
            return .invalidResponse
        case .badRequest(message: Constant.nicknameTooLong):
            return .nicknameTooLong
        case .badRequest(message: Constant.duplicateNickname):
            return .duplicateNickname
        case .noConnection, .invalidResponse, .noData:
            return .networkError
        default:
            return .unknown
        }
    }

    func mapToUserError(_ error: any Error) -> UserError {
        if let networkError = error as? NetworkError {
            return mapToUserError(networkError)
        }
        return .unknown
    }
}

private extension UserErrorMapper {
    struct Constant {
        static let userNotFound = "해당 유저가 존재하지 않습니다."
        static let duplicateNickname = "이미 존재하는 닉네임이에요."
        static let nicknameTooLong = "nickname must be shorter than or equal to 10 characters"
        static let deletedUser = "탈퇴한 회원입니다."
    }
}
