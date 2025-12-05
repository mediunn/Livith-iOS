//
//  LoginError.swift
//  LoginDomain
//
//  Created by 김진웅 on 12/5/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import Foundation

public enum LoginError: Error, LocalizedError {
    case canceled
    case noConnection
    case unknown
    
    public var errorDescription: String? {
        switch self {
        case .canceled:
            return "로그인이 취소되었습니다."
        case .noConnection:
            return "네트워크 연결을 확인해주세요."
        case .unknown:
            return "알 수 없는 오류가 발생했습니다."
        }
    }
}
