//
//  PreferenceErrorMapper.swift
//  PreferenceData
//
//  Created by 김진웅 on 2/4/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

import Domain
import LivithNetwork

struct PreferenceErrorMapper {
    func mapToPreferenceError(_ error: Error) -> PreferenceError {
        if error is CancellationError {
            return .cancelled
        }
        
        if let urlError = error as? URLError, urlError.code == .cancelled {
            return .cancelled
        }
        
        guard let networkError = error as? NetworkError else {
            return .unknown
        }
        
        return mapNetworkError(networkError)
    }
    
    private func mapNetworkError(_ error: NetworkError) -> PreferenceError {
        switch error {
        case .noConnection(let underlyingError):
            if let urlError = underlyingError as? URLError, urlError.code == .cancelled {
                return .cancelled
            }
            return .noConnection

        case .serverError:
            return .serverError

        case .timeout:
            return .noConnection

        case .cancelled:
            return .cancelled

        case .noData, .decodingFailed, .encodingFailed, .invalidURL, .invalidRequest, .invalidResponse:
            return .invalidResponse

        case .badRequest(let message):
            return mapFromMessage(message)

        case .unauthorized:
            return .unknown

        case .forbidden(let message):
            return mapFromMessage(message)

        case .notFound(let message):
            return mapFromMessage(message)

        case .clientError:
            return .invalidResponse

        case .unknown(let underlyingError):
            if let urlError = underlyingError as? URLError, urlError.code == .cancelled {
                return .cancelled
            }
            return .unknown
        }
    }
    
    private func mapFromMessage(_ message: String?) -> PreferenceError {
        guard let message else { return .unknown }
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
