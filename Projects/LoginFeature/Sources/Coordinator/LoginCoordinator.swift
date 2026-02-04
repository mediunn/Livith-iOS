//
//  LoginCoordinator.swift
//  LoginFeature
//
//  Created by 김진웅 on 12/27/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import SwiftUI
import UIKit

import LivithDesignSystem
import Coordinator
import Domain

final class LoginCoordinator: Coordinator {
    typealias R = LoginRoute
    
    let navigationController: UINavigationController
    
    private let onLoginCompleted: (() -> Void)
    private let onSignupCompleted: ((String) -> Void)
    
    init(
        onLoginCompleted: @escaping () -> Void = { },
        onSignupCompleted: @escaping (String) -> Void = { _ in }
    ) {
        self.navigationController = UINavigationController()
        self.onLoginCompleted = onLoginCompleted
        self.onSignupCompleted = onSignupCompleted
        
        self.navigationController.setNavigationBarHidden(true, animated: false)
    }
    
    func start() {
        push(to: .login, animated: false)
    }
    
    func buildViewController(for route: LoginRoute) -> UIViewController {
        switch route {
        case .login:
            return UIHostingController(rootView: LoginView().environment(\.loginCoordinator, self))
            
        case .terms(let tempUser):
            return UIHostingController(
                rootView: TermsView(tempUser: tempUser)
                    .environment(\.loginCoordinator, self)
            )
            
        case .nickname(let builder):
            return UIHostingController(
                rootView: NicknameSettingView(builder: builder)
                    .environment(\.loginCoordinator, self)
            )
            
        case .preferredGenre(let builder):
            return UIHostingController(
                rootView: PreferredGenreSettingView(builder: builder)
                    .environment(\.loginCoordinator, self)
            )
            
        case .safari(let url):
            let safariView = SafariView(url: url) { [weak self] in
                self?.dismiss()
            }.ignoresSafeArea()
            return UIHostingController(rootView: safariView)
        }
    }
    
    func completeLogin() {
        onLoginCompleted()
    }
    
    func completeSignup(with nickname: String) {
        onSignupCompleted(nickname)
    }
}

