//
//  AuthError.swift
//  Auth
//
//  Created by 김진웅 on 12/3/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import Foundation

public enum AuthError: Error, LocalizedError {
    case canceled
    case networkError
    case missingToken
    case unknown
    
    public var errorDescription: String? {
        switch self {
        case .canceled:
            return "로그인 과정이 취소되었습니다."
        case .networkError:
            return "네트워크 오류로 로그인에 실패했습니다."
        case .missingToken:
            return "인증 토큰을 받을 수 없습니다."
        case .unknown:
            return "알 수 없는 오류가 발생했습니다."
        }
    }
}
