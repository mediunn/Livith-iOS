//
//  NotificationError.swift
//  Domain
//
//  Created by Youjin Lee on 2/7/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

public enum NotificationError: DomainError {
    case noConnection
    case serverError
    case invalidResponse
    case unknown
    case notificationNotFound
    case cancelled

    public var errorDescription: String? {
        switch self {
        case .noConnection:
            return "네트워크 연결을 확인해주세요."
        case .serverError:
            return "서버 오류가 발생했어요."
        case .invalidResponse:
            return "데이터를 불러오는데 실패했어요."
        case .unknown:
            return "알 수 없는 오류가 발생했어요."
        case .notificationNotFound:
            return "알림을 찾을 수 없어요."
        case .cancelled:
            return "요청이 취소되었습니다."
        }
    }

    public static func from(message: String) -> NotificationError {
        switch message {
        case "해당 알림이 존재하지 않습니다.":
            return .notificationNotFound
        default:
            return .unknown
        }
    }
}
