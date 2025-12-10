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
    case noConnection
    case serverError
    case unknown
    
    public var errorDescription: String? {
        switch self {
        case .invalidNicknameFormat:
            return "닉네임 형식이 올바르지 않습니다. 영문, 한글, 숫자 1-10자로 입력해주세요."
            
        case .nicknameDuplicated:
            return "이미 사용 중인 닉네임입니다."
            
        case .noConnection:
            return "네트워크 연결을 확인해주세요."
            
        case .serverError:
            return "서버에 문제가 발생했습니다. 잠시 후 다시 시도해주세요."
            
        case .unknown:
            return "알 수 없는 오류가 발생했습니다. 잠시 후 다시 시도해주세요."
        }
    }
}
