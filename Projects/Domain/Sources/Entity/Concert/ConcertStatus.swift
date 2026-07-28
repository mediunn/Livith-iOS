//
//  ConcertStatus.swift
//  Domain
//
//  Created by 김진웅 on 1/21/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

public enum ConcertStatus: String, CaseIterable, Codable {
    case ongoing = "ONGOING"
    case upcoming = "UPCOMING"
    case completed = "COMPLETED"
    case canceled = "CANCELED"
    case past = "PAST"
}

public extension ConcertStatus {
    var statusChipText: String {
        switch self {
        case .ongoing:
            return "진행중"
        case .upcoming:
            return "D-"
        case .completed, .past:
            return "종료"
        case .canceled:
            return "공연취소"
        }
    }

    var filterText: String {
        switch self {
        case .ongoing:
            return "진행중"
        case .upcoming:
            return "진행예정"
        case .completed, .past:
            return "진행완료"
        case .canceled:
            return "공연취소"
        }
    }
}
