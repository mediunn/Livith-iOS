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
import LoginDomain
import DSKit

@MainActor
final class LoginRouter: Router {
    typealias Route = LoginRoute
    
    @Published var path: NavigationPath = NavigationPath()
    @Published var sheet: Route?
    @Published var fullScreenCover: Route?
    @Published var authenticationCompleted: Bool = false
    
    private var tempUser: TempUser?
    
    func view(to route: Route, with style: PresentationStyle) -> AnyView {
        switch route {
        case .login:
            return AnyView(LoginView())
            
        case .terms(let tempUser):
            self.tempUser = tempUser
            
            return AnyView(TermsView())
            
        case .nickname(let marketingConsent):
            guard let tempUser = tempUser else {
                return AnyView(EmptyView())
            }
            
            let store = NicknameSettingStore(marketingConsent: marketingConsent, tempUser: tempUser)
            return AnyView(NicknameSettingView(store: store))
            
        case .signupFailed:
            return AnyView(SignupFailedSheetView())
            
        case .safari(let url):
            let safariView = SafariView(url: url) { [weak self] in
                self?.dismissSheet()
            }
            .ignoresSafeArea()
            
            return AnyView(safariView)
        }
    }
    
    func completeAuthentication() {
        authenticationCompleted = true
    }
}
