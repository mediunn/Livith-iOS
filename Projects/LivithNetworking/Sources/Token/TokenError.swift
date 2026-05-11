//
//  TokenError.swift
//  LivithNetworking
//
//  Created by 김진웅 on 5/11/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

public enum TokenError: LocalizedError, Sendable {
    case saveFailed
    case loadFailed
    case deleteFailed
    case noToken
    case encodingFailed
    case decodingFailed
    case unknown

    public var errorDescription: String? {
        switch self {
        case .saveFailed:
            return "토큰 저장에 실패했습니다."
        case .loadFailed:
            return "토큰 조회에 실패했습니다."
        case .deleteFailed:
            return "토큰 삭제에 실패했습니다."
        case .noToken:
            return "저장된 토큰이 없습니다."
        case .encodingFailed:
            return "토큰 데이터를 인코딩하지 못했습니다."
        case .decodingFailed:
            return "토큰 데이터를 해석하지 못했습니다."
        case .unknown:
            return "알 수 없는 토큰 오류가 발생했습니다."
        }
    }
}
