//
//  SetlistType.swift
//  ConcertDomain
//
//  Created by Youjin Lee on 12/25/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import Foundation

public enum SetlistType: String, CaseIterable {
    case expected
    case recent
    case none
}

public extension SetlistType {
    init?(rawValue: String) {
        switch rawValue.uppercased() {
        case "EXPECTED":
            self = .expected
        case "RECENT":
            self = .recent
        default:
            self = .none
        }
    }

    var displayText: String {
        switch self {
        case .expected:
            return "예상"
        case .recent:
            return "최근"
        case .none:
            return ""
        }
    }
}
