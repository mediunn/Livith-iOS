//
//  LoginRouter.swift
//  LoginFeature
//
//  Created by 김진웅 on 12/8/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import Foundation
import SwiftUI

import Routing

@MainActor
final class LoginRouter: ObservableObject, Routing {
    typealias Route = LoginRoute
    
    @Published var path: NavigationPath = NavigationPath()
    @Published var sheet: Route?
    @Published var fullScreenCover: Route?
    
    func view(to route: Route, with style: PresentationStyle) -> AnyView {
        switch route {
        case .login:
            return AnyView(LoginView())
        case .terms:
            return AnyView(TermsView())
        case .nickname:
            return AnyView(NicknameSettingView())
        case .signupFailed:
            return AnyView(SignupFailedSheetView())
        }
    }
}
