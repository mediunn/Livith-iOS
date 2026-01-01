//
//  SongError.swift
//  SongDomain
//
//  Created by Youjin Lee on 1/1/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

public enum SongError: LocalizedError {
    case networkError
    case serverError
    case invalidResponse
    case notFound
    case unknown

    public var errorDescription: String? {
        switch self {
        case .networkError:
            return "네트워크 연결을 확인해주세요."
        case .serverError:
            return "서버 오류가 발생했어요."
        case .invalidResponse:
            return "데이터를 불러오는데 실패했어요."
        case .notFound:
            return "노래 정보를 찾을 수 없어요."
        case .unknown:
            return "알 수 없는 오류가 발생했어요."
        }
    }
}
