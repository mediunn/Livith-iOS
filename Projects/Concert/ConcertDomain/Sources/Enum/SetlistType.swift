//
//  SetlistType.swift
//  ConcertDomain
//
//  Created by Youjin Lee on 12/25/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import Foundation

public enum SetlistType: String, CaseIterable {
    case expected = "예상"
    case recent = "최근"
    case none = ""
}

public extension SetlistType {
    var displayText: String {
        return rawValue
    }
}
