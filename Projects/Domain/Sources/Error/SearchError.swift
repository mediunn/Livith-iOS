//
//  SearchError.swift
//  Domain
//
//  Created by 김진웅 on 1/21/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

public enum SearchError: DomainError {
    case noSearchResult
    case noConnection
    case serverError
    case invalidResponse
    case unknown
    case invalidGenre
    case invalidStatus
    case invalidSort
    case invalidSize
    case invalidCursor
    case invalidID
    case missingKeyword

    public var errorDescription: String? {
        switch self {
        case .noSearchResult:
            return "검색 결과가 없습니다."
        case .noConnection:
            return "네트워크 연결을 확인해주세요."
        case .serverError:
            return "서버에 문제가 발생했습니다. 잠시 후 다시 시도해주세요."
        case .invalidResponse:
            return "데이터를 불러오는데 실패했습니다."
        case .unknown:
            return "알 수 없는 오류가 발생했습니다."
        case .invalidGenre:
            return "유효하지 않은 장르입니다."
        case .invalidStatus:
            return "유효하지 않은 상태값입니다."
        case .invalidSort:
            return "유효하지 않은 정렬값입니다."
        case .invalidSize:
            return "사이즈는 양의 정수여야 합니다."
        case .invalidCursor:
            return "유효하지 않은 커서 형식입니다."
        case .invalidID:
            return "ID는 1 이상의 정수여야 합니다."
        case .missingKeyword:
            return "검색어는 필수입니다."
        }
    }
    
    public static func from(message: String) -> SearchError {
        switch message {
        case "genre는 JPOP | ROCK_METAL | RAP_HIPHOP | CLASSIC_JAZZ | ACOUSTIC | ELECTRONIC | ALL 중 하나여야 해요":
            return .invalidGenre
        case "status는 ONGOING | UPCOMING | COMPLETED | ALL 중 하나여야 해요":
            return .invalidStatus
        case "sort는 LATEST | ALPHABETICAL 중 하나여야 해요":
            return .invalidSort
        case "size must be a positive number", "size must not be less than 1":
            return .invalidSize
        case "유효하지 않은 cursor 형식입니다.":
            return .invalidCursor
        case "id must not be less than 1":
            return .invalidID
        case "검색어(letter)는 필수입니다.":
            return .missingKeyword
        default:
            return .unknown
        }
    }
}
