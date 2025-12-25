//
//  ConcertError.swift
//  ConcertDomain
//
//  Created by Youjin Lee on 12/25/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import Foundation

public enum ConcertError: LocalizedError {
    case notFound
    case networkError
    case serverError
    case invalidResponse
    case unauthorized
    case forbidden
    case unknown

    public var errorDescription: String? {
        switch self {
        case .notFound:
            return "콘서트를 찾을 수 없습니다."
        case .networkError:
            return "네트워크 연결을 확인해주세요."
        case .serverError:
            return "서버에 문제가 발생했습니다. 잠시 후 다시 시도해주세요."
        case .invalidResponse:
            return "데이터를 불러오는데 실패했습니다."
        case .unauthorized:
            return "로그인이 필요합니다."
        case .forbidden:
            return "접근 권한이 없습니다."
        case .unknown:
            return "알 수 없는 오류가 발생했습니다."
        }
    }
}
