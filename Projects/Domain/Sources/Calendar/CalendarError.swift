//
//  CalendarError.swift
//  Domain
//
//  Created by 김진웅 on 7/23/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

public enum CalendarError: DomainError {
    case noConnection
    case serverError
    case invalidResponse
    case invalidRequest
    case unauthorized
    case cancelled
    case unknown

    public var errorDescription: String? {
        switch self {
        case .noConnection:
            return "네트워크 연결을 확인해주세요."
        case .serverError:
            return "서버 오류가 발생했어요."
        case .invalidResponse:
            return "데이터를 불러오는데 실패했어요."
        case .invalidRequest:
            return "잘못된 요청입니다."
        case .unauthorized:
            return "인증이 필요해요."
        case .cancelled:
            return "요청이 취소되었습니다."
        case .unknown:
            return "알 수 없는 오류가 발생했어요."
        }
    }

    public static func from(message: String) -> CalendarError {
        _ = message
        return .unknown
    }
}
