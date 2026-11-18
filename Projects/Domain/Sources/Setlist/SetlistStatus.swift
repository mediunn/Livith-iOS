//
//  SetlistStatus.swift
//  Domain
//
//  Created by 김진웅 on 1/22/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

public enum SetlistStatus: String, CaseIterable, CustomStringConvertible {
    case represent = "대표"
    case expected = "예상"
    case recent = "최근"
    
    public var description: String {
        rawValue
    }
}
