//
//  CalendarErrorMapper.swift
//  CalendarData
//
//  Created by 김진웅 on 7/23/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

import Domain
import LivithNetworking

struct CalendarErrorMapper {
    func mapToCalendarError(_ error: any Error) -> CalendarError {
        if let calendarError = checkForCancellation(error) {
            return calendarError
        }

        guard let networkError = error as? NetworkError else { return .unknown }

        return mapToCalendarError(networkError)
    }
}

// MARK: - Private

private extension CalendarErrorMapper {
    func mapToCalendarError(_ networkError: NetworkError) -> CalendarError {
        if let message = extractMessage(from: networkError),
           let calendarError = mapMessageToCalendarError(message) {
            return calendarError
        }

        switch networkError {
        case .noConnection:
            return .noConnection
        case .serverError:
            return .serverError
        case .timeout:
            return .noConnection
        case .cancelled:
            return .cancelled
        case .noData:
            return .invalidResponse
        case .decodingFailed, .encodingFailed, .invalidURL, .invalidRequest, .invalidResponse, .badRequest, .clientError:
            return .invalidResponse
        case .unauthorized, .forbidden:
            return .unauthorized
        case .notFound, .unknown:
            return .unknown
        }
    }

    func extractMessage(from networkError: NetworkError) -> String? {
        switch networkError {
        case .badRequest(let msg),
             .unauthorized(let msg),
             .forbidden(let msg),
             .notFound(let msg),
             .serverError(_, let msg),
             .clientError(_, let msg):
            return msg
        default:
            return nil
        }
    }

    func mapMessageToCalendarError(_ message: String) -> CalendarError? {
        let error = CalendarError.from(message: message)
        return error == .unknown ? nil : error
    }

    func checkForCancellation(_ error: any Error) -> CalendarError? {
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
