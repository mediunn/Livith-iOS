//
//  NetworkError.swift
//  network
//
//  Created by Youjin Lee on 10/12/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import Foundation

public enum NetworkError: Error {
    
    // MARK: Request Error
    
    case invalidURL
    case invalidRequest

    // MARK: Response Error
    
    case noData
    case invalidResponse
    case decodingFailed(Error)

    // MARK: HTTP Error
    
    case badRequest(message: String?)
    case unauthorized(message: String?)
    case forbidden(message: String?)
    case notFound(message: String?)
    case serverError(message: String?)
    case clientError(statusCode: Int, message: String?)

    // MARK: Unknown Error
    
    case unknown(Error)
}

extension NetworkError {
    static func from(statusCode: Int, message: String? = nil) -> NetworkError {
        switch statusCode {
        case 400:
            return .badRequest(message: message)
        case 401:
            return .unauthorized(message: message)
        case 403:
            return .forbidden(message: message)
        case 404:
            return .notFound(message: message)
        case 400 ..< 500:
            return .clientError(statusCode: statusCode, message: message)
        case 500 ..< 600:
            return .serverError(message: message)
        default:
            return .invalidResponse
        }
    }
}

extension NetworkError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "유효하지 않은 URL입니다."
        case .invalidRequest:
            return "잘못된 요청입니다."
        case .invalidResponse:
            return "서버 응답이 유효하지 않습니다."
        case .noData:
            return "응답 데이터가 없습니다."

        case .badRequest(let message):
            return "잘못된 요청입니다 (400): \(message ?? "")"
        case .unauthorized(let message):
            return "인증이 필요합니다 (401): \(message ?? "")"
        case .forbidden(let message):
            return "접근 권한이 없습니다 (403): \(message ?? "")"
        case .notFound(let message):
            return "요청한 리소스를 찾을 수 없습니다 (404): \(message ?? "")"
        case .serverError(let message):
            return "서버 에러가 발생했습니다 (5xx): \(message ?? "")"
        case .clientError(let statusCode, let message):
            return "클라이언트 에러입니다 (\(statusCode)): \(message ?? "")"

        case .decodingFailed(let error):
            return "데이터 디코딩에 실패했습니다: \(error.localizedDescription)"
        case .unknown(let error):
            return "알 수 없는 에러입니다: \(error.localizedDescription)"
        }
    }
}
