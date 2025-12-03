//
//  OnboardingRoute.swift
//  LoginFeature
//
//  Created by 김진웅 on 11/8/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import Foundation

import Routing

enum OnboardingRoute: String, Routable {
    case terms
    case nickname
    case signupFailed
    
    var id: String { rawValue }
}
