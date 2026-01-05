//
//  SetlistType.swift
//  HomeDomain
//
//  Created by 김진웅 on 1/2/26.
//  Copyright © 2025 Livith. All rights reserved.
//

import Foundation

public enum SetlistType: String, CaseIterable {
    case expected = "EXPECTED"
    case recent = "RECENT"
    case past = "PAST"
    case none = "NONE"

    public var displayText: String {
        switch self {
        case .expected:
            return "예상 셋리스트"
        case .recent, .past, .none:
            return "셋리스트"
        }
    }

    public var isPastSetlist: Bool {
        switch self {
        case .recent, .past:
            return true
        case .expected, .none:
            return false
        }
    }
}
