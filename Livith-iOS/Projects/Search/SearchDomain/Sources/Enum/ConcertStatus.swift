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
        }
    }
}
