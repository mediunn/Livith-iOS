//
//  HomeError.swift
//  HomeDomain
//
//  Created by 김진웅 on 12/26/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import Foundation

public enum HomeError: Error, LocalizedError {
    case noConnection
    case serverError
    case unknown
    
    public var errorDescription: String? {
        switch self {
        case .noConnection:
            return "네트워크 연결이 없습니다. 연결 상태를 확인해주세요."
        case .serverError:
            return "서버에 문제가 발생했습니다. 잠시 후 다시 시도해주세요."
        case .unknown:
            return "알 수 없는 오류가 발생했습니다. 잠시 후 다시 시도해주세요."
        }
    }
}
