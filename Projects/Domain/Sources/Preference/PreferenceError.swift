//
//  PreferenceError.swift
//  Domain
//
//  Created by 김진웅 on 2/4/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

public enum PreferenceError: DomainError {
    // MARK: - Common
    case noConnection
    case serverError
    case invalidResponse
    case unknown
    case cancelled
    
    // MARK: - User
    case userNotFound
    case withdrawn
    
    // MARK: - Cursor/Pagination
    case invalidCursor
    case invalidSize
    
    // MARK: - Genre
    case genreNotFound
    case minGenreRequired
    case maxGenreExceeded
    case invalidGenreID
    
    // MARK: - Artist
    case artistNotFound
    case maxArtistExceeded
    case invalidArtistID
    
    public var errorDescription: String? {
        switch self {
        case .noConnection:
            return "네트워크 연결을 확인해주세요."
        case .serverError:
            return "서버에 문제가 발생했습니다. 잠시 후 다시 시도해주세요."
        case .invalidResponse:
            return "데이터를 불러오는데 실패했습니다."
        case .unknown:
            return "알 수 없는 오류가 발생했습니다."
        case .cancelled:
            return "요청이 취소되었습니다."
        case .userNotFound:
            return "해당 유저가 존재하지 않습니다."
        case .withdrawn:
            return "탈퇴한 회원입니다."
        case .invalidCursor:
            return "잘못된 커서 값입니다."
        case .invalidSize:
            return "잘못된 사이즈 값입니다."
        case .genreNotFound:
            return "해당 장르를 찾을 수 없습니다."
        case .minGenreRequired:
            return "최소 1개의 장르는 선택해야 합니다."
        case .maxGenreExceeded:
            return "최대 3개의 장르만 선택할 수 있습니다."
        case .invalidGenreID:
            return "장르 ID는 숫자여야 합니다."
        case .artistNotFound:
            return "해당 아티스트를 찾을 수 없습니다."
        case .maxArtistExceeded:
            return "최대 3개의 아티스트만 선택할 수 있습니다."
        case .invalidArtistID:
            return "아티스트 ID는 숫자여야 합니다."
        }
    }
    
    public static func from(message: String) -> PreferenceError {
        switch message {
        // User
        case "해당 유저가 존재하지 않습니다.":
            return .userNotFound
        case "탈퇴한 회원입니다.":
            return .withdrawn
            
        // Cursor/Pagination
        case "cursor must not be less than 1":
            return .invalidCursor
        case "size must not be less than 1":
            return .invalidSize
            
        // Genre
        case "해당 장르를 찾을 수 없습니다.":
            return .genreNotFound
        case "최소 1개의 장르는 선택해야 합니다.":
            return .minGenreRequired
        case "최대 3개의 장르만 선택할 수 있습니다.":
            return .maxGenreExceeded
        case "장르 ID는 숫자여야 합니다.":
            return .invalidGenreID
            
        // Artist
        case "해당 아티스트를 찾을 수 없습니다.":
            return .artistNotFound
        case "최대 3개의 아티스트만 선택할 수 있습니다.":
            return .maxArtistExceeded
        case "아티스트 ID는 숫자여야 합니다.":
            return .invalidArtistID
            
        default:
            return .unknown
        }
    }
}
