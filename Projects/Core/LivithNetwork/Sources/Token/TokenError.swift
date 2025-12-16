//
//  TokenError.swift
//  LivithNetwork
//
//  Created by 김진웅 on 12/7/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import Foundation

public enum TokenError: Error, LocalizedError {
    case saveFailed
    case deleteFailed
    case noData
    case refreshTokenExpired
    case networkError
    case unknown
    
    public var errorDescription: String? {
        switch self {
        case .saveFailed:
            return "토큰 저장에 실패했습니다."
        case .deleteFailed:
            return "토큰 삭제에 실패했습니다."
        case .noData:
            return "토큰 데이터가 없습니다."
        case .refreshTokenExpired:
            return "리프레시 토큰이 만료되었습니다."
        case .networkError:
            return "네트워크 오류로 인해 토큰 작업에 실패했습니다."
        case .unknown:
            return "알 수 없는 토큰 오류가 발생했습니다."
        }
    }
}
