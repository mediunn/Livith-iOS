//
//  ConcertError.swift
//  Domain
//
//  Created by 김진웅 on 1/21/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

public enum ConcertError: DomainError {
    case noConnection
    case serverError
    case invalidResponse
    case invalidRequest
    case unknown
    case invalidID
    case invalidSize
    case concertNotFound
    case artistNotFound
    case cancelled
    
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
        case .unknown:
            return "알 수 없는 오류가 발생했어요."
        case .invalidID, .invalidSize:
            return "잘못된 요청입니다."
        case .concertNotFound:
            return "콘서트를 찾을 수 없어요."
        case .artistNotFound:
            return "아티스트를 찾을 수 없어요."
        case .cancelled:
            return "요청이 취소되었습니다."
        }
    }
    
    public static func from(message: String) -> ConcertError {
        switch message {
        case "id는 양의 정수여야 합니다.", "id must not be less than 1":
            return .invalidID
        case "size must not be less than 1":
            return .invalidSize
        case "해당 콘서트를 찾을 수 없습니다.", "해당 콘서트가 존재하지 않습니다.":
            return .concertNotFound
        case "해당 아티스트를 찾을 수 없습니다.":
            return .artistNotFound
        default:
            return .unknown
        }
    }
}
