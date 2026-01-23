//
//  LoginRoute.swift
//  LoginFeature
//
//  Created by 김진웅 on 12/27/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import Foundation

import LivithDesignSystem
import Coordinator
import LoginDomain

enum LoginRoute: Route {
    case login
    case loginForbidden
    case terms(LoginDomain.TempUser)
    case nickname(Bool)
    case signupFailed
    case safari(URL)
}
