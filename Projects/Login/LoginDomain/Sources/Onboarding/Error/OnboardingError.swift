//
//  OnboardingError.swift
//  LoginDomain
//
//  Created by 김진웅 on 11/10/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import Foundation

public enum OnboardingError: LocalizedError {
    case invalidNicknameFormat
    case nicknameDuplicated
    case signupFailed(reason: String)
    case networkError
    case unknown
    
    public var errorDescription: String? {
        switch self {
        case .invalidNicknameFormat:
            return "닉네임 형식이 올바르지 않습니다. 영문, 한글, 숫자 1-10자로 입력해주세요."
            
        case .nicknameDuplicated:
            return "이미 사용 중인 닉네임입니다."
            
        case .signupFailed(let reason):
            return "회원가입에 실패했습니다. \(reason)"
            
        case .networkError:
            return "네트워크 연결을 확인해주세요."
            
        case .unknown:
            return "알 수 없는 오류가 발생했습니다."
        }
    }
}
