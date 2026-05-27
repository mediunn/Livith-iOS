//
//  NotificationErrorMapper.swift
//  NotificationData
//
//  Created by Youjin Lee on 2/7/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

import Domain
import LivithNetworking

struct NotificationErrorMapper {
    func mapToNotificationError(_ error: Error) -> NotificationError {
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

    private func mapNetworkError(_ error: NetworkError) -> NotificationError {
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

    private func mapFromMessage(_ message: String?) -> NotificationError {
        guard let message else { return .unknown }
        return NotificationError.from(message: message)
    }
}
