//
//  ConcertMatchingErrorMapper.swift
//  UserData
//
//  Created by youz2me on 7/20/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

import Domain
import LivithNetworking

struct ConcertMatchingErrorMapper {
    func mapToConcertMatchingError(_ error: any Error) -> ConcertMatchingError {
        if let matchingError = checkForCancellation(error) {
            return matchingError
        }

        if let networkError = error as? NetworkError {
            return mapToConcertMatchingError(networkError)
        }

        return .unknown
    }

    private func mapToConcertMatchingError(_ networkError: NetworkError) -> ConcertMatchingError {
        switch networkError {
        case .noConnection, .timeout:
            return .noConnection
        case .cancelled:
            return .cancelled
        case .serverError:
            return .serverError
        case .badRequest, .notFound, .noData:
            return .matchFailed
        case .decodingFailed, .encodingFailed, .invalidResponse, .clientError, .invalidURL, .invalidRequest:
            return .invalidResponse
        case .unauthorized, .forbidden, .unknown:
            return .unknown
        }
    }

    private func checkForCancellation(_ error: any Error) -> ConcertMatchingError? {
        if error is CancellationError {
            return .cancelled
        }

        if let urlError = error as? URLError, urlError.code == .cancelled {
            return .cancelled
        }

        if let networkError = error as? NetworkError {
            switch networkError {
            case .noConnection(let wrappedError), .unknown(let wrappedError):
                return checkForCancellation(wrappedError)
            default:
                return nil
            }
        }

        return nil
    }
}
