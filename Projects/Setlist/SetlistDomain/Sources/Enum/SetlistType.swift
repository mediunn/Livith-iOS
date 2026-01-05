//
//  SetlistType.swift
//  SetlistDomain
//
//  Created by Youjin Lee on 12/30/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import Foundation

public enum SetlistType: String, CaseIterable {
    case expected = "EXPECTED"
    case recent = "RECENT"
    case none = "NONE"

    public var displayText: String {
        switch self {
        case .expected:
            return "예상 셋리스트"
        case .recent, .none:
            return "셋리스트"
        }
    }

    public var badgeText: String? {
        switch self {
        case .expected:
            return "예상"
        case .recent:
            return "최근"
        case .none:
            return nil
        }
    }
}
