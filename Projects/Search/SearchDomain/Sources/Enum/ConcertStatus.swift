//
//  ConcertStatus.swift
//  search
//
//  Created by Youjin Lee on 10/27/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import Foundation

public enum ConcertStatus: String {
    case ongoing
    case upcoming
    case completed
    case canceled
}

public extension ConcertStatus {
    init?(rawValue: String) {
        switch rawValue.uppercased() {
        case "ONGOING":
            self = .ongoing
        case "UPCOMING":
            self = .upcoming
        case "COMPLETED":
            self = .completed
        case "CANCELED":
            self = .canceled
        default:
            return nil
        }
    }
    
    var rawValue: String {
        switch self {
        case .ongoing:
            return "ONGOING"
        case .upcoming:
            return "UPCOMING"
        case .completed:
            return "COMPLETED"
        case .canceled:
            return "CANCELED"
        }
    }
    
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
