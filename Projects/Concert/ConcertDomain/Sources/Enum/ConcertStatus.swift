//
//  ConcertStatus.swift
//  ConcertDomain
//
//  Created by Youjin Lee on 10/27/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import Foundation

public enum ConcertStatus: String, CaseIterable {
    case ongoing = "ONGOING"
    case upcoming = "UPCOMING"
    case completed = "COMPLETED"
    case canceled = "CANCELED"
}

public extension ConcertStatus {
    var statusChipText: String {
        switch self {
        case .ongoing:
            return "진행중"
        case .upcoming:
            return "D-"
        case .completed:
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
        case .completed:
            return "진행완료"
        case .canceled:
            return "공연취소"
        }
    }
}
