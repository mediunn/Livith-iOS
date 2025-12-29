//
//  TokenError.swift
//  LivithNetwork
//
//  Created by 김진웅 on 12/7/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import Foundation

public enum TokenError: Error, LocalizedError {
    case storage(StorageError)
    case refresh(RefreshError)
    case unknown
    
    // MARK: - Storage Error
    
    public enum StorageError: Error, LocalizedError {
        case saveFailed
        case deleteFailed
        case noData
        case refreshTokenExpired
        
        public var errorDescription: String? {
            switch self {
            case .saveFailed:
                return "토큰 저장에 실패했습니다."
            case .deleteFailed:
                return "토큰 삭제에 실패했습니다."
            case .noData:
                return "토큰 데이터가 없습니다."
            case .refreshTokenExpired:
                return "리프레시 토큰이 만료되었습니다."
            }
        }
    }
    
    // MARK: - Refresh Error
    
    public enum RefreshError: Error, LocalizedError {
        case badRequest
        case unauthorized
        case forbidden
        case notFound
        case serverError
        case noConnection
        case decodingFailed
        case emptyResponse
        
        public var errorDescription: String? {
            switch self {
            case .badRequest:
                return "잘못된 요청입니다. 요청 형식을 확인해주세요."
            case .unauthorized:
                return "인증에 실패했습니다."
            case .forbidden:
                return "해당 작업에 대한 권한이 없습니다."
            case .notFound:
                return "요청한 리소스를 찾을 수 없습니다."
            case .serverError:
                return "서버 오류가 발생했습니다. 잠시 후 다시 시도해주세요."
            case .noConnection:
                return "네트워크 연결에 실패했습니다. 인터넷 연결을 확인해주세요."
            case .decodingFailed:
                return "서버 응답을 처리하는 데 실패했습니다."
            case .emptyResponse:
                return "서버에서 빈 응답을 받았습니다."
            }
        }
    }
    
    // MARK: - Error Description
    
    public var errorDescription: String? {
        switch self {
        case .storage(let error):
            return error.errorDescription
        case .refresh(let error):
            return error.errorDescription
        case .unknown:
            return "알 수 없는 토큰 오류가 발생했습니다."
        }
    }
}
