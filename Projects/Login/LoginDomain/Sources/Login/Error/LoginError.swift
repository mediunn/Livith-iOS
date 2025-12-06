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
    case loginFailed
    case serverError
    case noData
    case unknown
    
    public var errorDescription: String? {
        switch self {
        case .canceled:
            return "로그인이 취소되었습니다."
        case .noConnection:
            return "네트워크 연결을 확인해주세요."
        case .loginFailed:
            return "로그인에 실패했습니다. 다시 시도해주세요."
        case .serverError:
            return "서버에 문제가 발생했습니다. 잠시 후 다시 시도해주세요."
        case .noData:
            return "데이터를 불러올 수 없습니다."
        case .unknown:
            return "알 수 없는 오류가 발생했습니다."
        }
    }
}
