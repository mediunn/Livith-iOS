//
//  LoginRoute.swift
//  LoginFeature
//
//  Created by 김진웅 on 12/8/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import Foundation

import Router
import LoginDomain

enum LoginRoute: Route {
    case login
    case terms(TempUser)
    case nickname(Bool)
    case signupFailed
    case safari(URL)
    
    var id: String {
        switch self {
        case .login: "login"
        case .terms: "terms"
        case .nickname: "nickname"
        case .signupFailed: "signupFailed"
        case .safari: "safari"
        }
    }
}
