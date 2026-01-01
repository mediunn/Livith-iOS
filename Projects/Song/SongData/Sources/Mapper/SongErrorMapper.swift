//
//  SongErrorMapper.swift
//  SongData
//
//  Created by Youjin Lee on 1/1/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

import LivithNetwork
import SongDomain

struct SongErrorMapper {
    func mapToSongError(_ error: any Error) -> SongError {
        if let networkError = error as? NetworkError {
            return mapToSongError(networkError)
        }
        return .unknown
    }

    func mapToSongError(_ networkError: NetworkError) -> SongError {
        switch networkError {
        case .noConnection:
            return .networkError
        case .serverError:
            return .serverError
        case .noData, .notFound:
            return .notFound
        case .decodingFailed, .invalidURL, .invalidRequest, .invalidResponse, .badRequest, .clientError:
            return .invalidResponse
        case .unauthorized, .forbidden, .unknown:
            return .unknown
        }
    }
}
