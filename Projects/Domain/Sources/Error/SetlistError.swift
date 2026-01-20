//
//  SetlistError.swift
//  Domain
//
//  Created by 김진웅 on 1/21/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

public enum SetlistError: DomainError {
    case noConnection
    case serverError
    case invalidResponse
    case notFound
    case unknown
    case invalidID
    case concertNotFound
    case combinationNotFound
    case cancelled
    
    public var errorDescription: String? {
        switch self {
        case .noConnection:
            return "네트워크 연결을 확인해주세요."
        case .serverError:
            return "서버 오류가 발생했어요."
        case .invalidResponse:
            return "데이터를 불러오는데 실패했어요."
        case .notFound:
            return "셋리스트를 찾을 수 없어요."
        case .unknown:
            return "알 수 없는 오류가 발생했어요."
        case .invalidID:
            return "잘못된 요청입니다."
        case .concertNotFound:
            return "콘서트를 찾을 수 없어요."
        case .combinationNotFound:
            return "해당 셋리스트에 포함된 콘서트가 아니에요."
        case .cancelled:
            return "요청이 취소되었습니다."
        }
    }
    
    public static func from(message: String) -> SetlistError {
        switch message {
        case "id는 양의 정수여야 합니다.":
            return .invalidID
        case "해당 셋리스트가 존재하지 않습니다.":
            return .notFound
        case "해당 콘서트가 찾을 수 없습니다.":
            return .concertNotFound
        case "해당 셋리스트와 콘서트의 조합이 존재하지 않습니다.":
            return .combinationNotFound
        default:
            return .unknown
        }
    }
}
