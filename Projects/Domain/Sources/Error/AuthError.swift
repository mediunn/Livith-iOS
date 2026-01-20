//
//  AuthError.swift
//  Domain
//
//  Created by 김진웅 on 1/21/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

public enum AuthError: LocalizedError {
    // Common
    case noConnection
    case serverError
    case invalidResponse
    case unknown
    case forbidden
    case notFound
    
    // Login specific
    case canceled
    case noData
    
    // User specific
    case duplicateNickname
    case nicknameTooLong
    
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
        case .forbidden:
            return "접근 권한이 없습니다."
        case .notFound:
            return "정보를 찾을 수 없습니다."
        case .canceled:
            return "로그인이 취소되었습니다."
        case .noData:
            return "데이터를 불러올 수 없습니다."
        case .duplicateNickname:
            return "이미 사용 중인 닉네임입니다."
        case .nicknameTooLong:
            return "닉네임이 너무 깁니다."
        }
    }
}
