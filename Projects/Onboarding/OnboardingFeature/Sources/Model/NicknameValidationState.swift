//
//  NicknameValidationState.swift
//  OnboardingFeature
//
//  Created by 김진웅 on 11/10/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import Foundation

enum NicknameValidationState {
    case idle
    case valid
    case invalid
    case checking
    case available
    case duplicate
}
