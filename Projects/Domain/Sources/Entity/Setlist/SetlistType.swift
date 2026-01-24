//
//  SetlistType.swift
//  Domain
//
//  Created by 김진웅 on 1/21/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

public enum SetlistType: String, CaseIterable, CustomStringConvertible {
    case expected = "EXPECTED"
    case recent = "RECENT"
    case ongoing = "ONGOING"
    case past = "PAST"
    case none = "NONE"
    
    public init(value: String) {
        self = .init(rawValue: value.uppercased()) ?? .none
    }
    
    public var description: String {
        switch self {
        case .expected:
            "예상"
        case .recent:
            "최근"
        case .ongoing:
            "진행중"
        case .past:
            "최근"
        case .none:
            ""
        }
    }

    public var isPastSetlist: Bool {
        self == .past || self == .recent
    }
}
