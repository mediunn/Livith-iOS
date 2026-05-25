//
//  NetworkError.swift
//  LivithNetworking
//
//  Created by 김진웅 on 5/9/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

public enum NetworkError: LocalizedError {
    case invalidURL
    case invalidRequest
    case encodingFailed(Error)
    case noConnection(Error)
    case timeout(Error)
    case cancelled
    case invalidResponse
    case noData
    case decodingFailed(Error)
    case badRequest(message: String?)
    case unauthorized(message: String?)
    case forbidden(message: String?)
    case notFound(message: String?)
    case clientError(statusCode: Int, message: String?)
    case serverError(statusCode: Int, message: String?)
    case unknown(Error)

    public var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "유효하지 않은 URL입니다."
        case .invalidRequest:
            return "잘못된 요청입니다."
        case .encodingFailed(let error):
            return "요청 데이터를 인코딩하지 못했습니다: \(error.localizedDescription)"
        case .noConnection(let error):
            return "네트워크 연결을 확인해주세요: \(error.localizedDescription)"
        case .timeout(let error):
            return "요청 시간이 초과되었습니다: \(error.localizedDescription)"
        case .cancelled:
            return "요청이 취소되었습니다."
        case .invalidResponse:
            return "서버 응답이 유효하지 않습니다."
        case .noData:
            return "응답 데이터가 없습니다."
        case .decodingFailed(let error):
            return "응답 데이터를 해석하지 못했습니다: \(error.localizedDescription)"
        case .badRequest(let message):
            return description("잘못된 요청입니다 (400)", message: message)
        case .unauthorized(let message):
            return description("인증이 필요합니다 (401)", message: message)
        case .forbidden(let message):
            return description("접근 권한이 없습니다 (403)", message: message)
        case .notFound(let message):
            return description("요청한 리소스를 찾을 수 없습니다 (404)", message: message)
        case .clientError(let statusCode, let message):
            return description("클라이언트 에러입니다 (\(statusCode))", message: message)
        case .serverError(let statusCode, let message):
            return description("서버 에러가 발생했습니다 (\(statusCode))", message: message)
        case .unknown(let error):
            return "알 수 없는 에러입니다: \(error.localizedDescription)"
        }
    }
}

public extension NetworkError {
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
        case 400..<500:
            return .clientError(statusCode: statusCode, message: message)
        case 500..<600:
            return .serverError(statusCode: statusCode, message: message)
        default:
            return .invalidResponse
        }
    }
}

private extension NetworkError {
    func description(
        _ baseDescription: String,
        message: String?
    ) -> String {
        guard let message, !message.isEmpty else {
            return baseDescription
        }

        return "\(baseDescription): \(message)"
    }
}
