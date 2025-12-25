//
//  ScheduleType.swift
//  Concert
//
//  Created by Youjin Lee on 12/27/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import Foundation

public enum ScheduleType: String, CaseIterable, Codable {
    case ticketing
    case none
}

public extension ScheduleType {
    init?(rawValue: String) {
        switch rawValue.uppercased() {
        case "TICKETING":
            self = .ticketing
        default:
            self = .none
        }
    }
    
    var rawValue: String {
        switch self {
        case .ticketing:
            return "TICKETING"
        default:
            return "NONE"
        }
    }
}
