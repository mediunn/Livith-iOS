//
//  SetlistType+Extension.swift
//  SetlistFeature
//
//  Created by Youjin Lee on 1/24/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Domain

extension SetlistType {
    var displayText: String {
        switch self {
        case .expected:
            return "예상 셋리스트"
        case .recent, .ongoing, .past, .none:
            return "셋리스트"
        }
    }
}
