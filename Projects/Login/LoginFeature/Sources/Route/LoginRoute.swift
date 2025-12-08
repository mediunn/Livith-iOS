//
//  LoginRoute.swift
//  LoginFeature
//
//  Created by 김진웅 on 12/8/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import Foundation

import Routing

enum LoginRoute: Routable {
    case login
    case terms
    case nickname
    case signupFailed
    
    var id: String {
        switch self {
        case .login: "login"
        case .terms: "terms"
        case .nickname: "nickname"
        case .signupFailed: "signupFailed"
        }
    }
}
