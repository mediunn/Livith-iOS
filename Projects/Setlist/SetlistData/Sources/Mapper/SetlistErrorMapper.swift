//
//  SetlistErrorMapper.swift
//  SetlistData
//
//  Created by Youjin Lee on 12/30/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import Foundation

import LivithNetwork
import SetlistDomain

struct SetlistErrorMapper {
    func mapToSetlistError(_ error: any Error) -> SetlistError {
        if let networkError = error as? NetworkError {
            return mapToSetlistError(networkError)
        }
        return .unknown
    }

    func mapToSetlistError(_ networkError: NetworkError) -> SetlistError {
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
