//
//  ConcertMatchingError.swift
//  Domain
//
//  Created by youz2me on 7/8/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

public enum ConcertMatchingError: DomainError {
    case noConnection
    case serverError
    case invalidResponse
    case matchFailed
    case unknown
    case cancelled

    public var errorDescription: String? {
        switch self {
        case .noConnection:
            return "네트워크 연결을 확인해주세요."
        case .serverError:
            return "서버에 문제가 발생했습니다. 잠시 후 다시 시도해주세요."
        case .invalidResponse:
            return "데이터를 불러오는데 실패했습니다."
        case .matchFailed:
            return "공연 정보를 불러오지 못했어요."
        case .unknown:
            return "알 수 없는 오류가 발생했습니다."
        case .cancelled:
            return "요청이 취소되었습니다."
        }
    }

    public static func from(message: String) -> ConcertMatchingError {
        .unknown
    }
}
