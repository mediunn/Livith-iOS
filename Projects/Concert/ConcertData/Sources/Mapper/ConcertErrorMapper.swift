//
//  ConcertErrorMapper.swift
//  ConcertData
//
//  Created by Youjin Lee on 12/25/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import Foundation

import ConcertDomain
import LivithNetwork

struct ConcertErrorMapper {
    func mapToConcertError(_ error: Error) -> ConcertError {
        guard let networkError = error as? NetworkError else {
            return .unknown
        }

        switch networkError {
        case .noData:
            return .notFound
        case .noConnection:
            return .networkError
        case .serverError:
            return .serverError
        case .decodingFailed, .invalidResponse:
            return .invalidResponse
        case .unauthorized:
            return .unauthorized
        case .forbidden:
            return .forbidden
        default:
            return .unknown
        }
    }
}
