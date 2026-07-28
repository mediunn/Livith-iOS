//
//  NicknameValidationState.swift
//  NicknameEdit
//
//  Created by Youjin Lee on 1/23/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

public enum NicknameValidationState: Equatable {
    case idle
    case valid
    case invalid
    case checking
    case available
    case duplicate
}
