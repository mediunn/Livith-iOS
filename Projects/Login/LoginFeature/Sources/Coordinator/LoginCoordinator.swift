//
//  LoginCoordinator.swift
//  LoginFeature
//
//  Created by 김진웅 on 12/27/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import SwiftUI
import UIKit

import DSKit
import LoginDomain

@Observable
final class LoginCoordinator: Coordinator {
    typealias R = LoginRoute
    
    let navigationController: UINavigationController
    
    private var tempUser: TempUser?

    private let onLoginCompleted: ((String) -> Void)
    private let onSignupCompleted: ((String) -> Void)
    
    init(
        onLoginCompleted: @escaping (String) -> Void = { _ in },
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
            return UIHostingController(rootView: LoginView().environment(self))
            
        case .loginForbidden:
            return UIHostingController(
                rootView: ErrorSheetView(
                    title: "탈퇴 후 7일이 지나지 않았어요",
                    message: "7일이 지난 후 다시 시도해주세요"
                ) { [weak self] in
                    self?.dismiss()
                }
            )
            
        case .terms(let tempUser):
            self.tempUser = tempUser
            return UIHostingController(rootView: TermsView().environment(self))
            
        case .nickname(let marketingConsent):
            guard let tempUser = tempUser else {
                return UIHostingController(rootView: EmptyView())
            }

            let store = NicknameSettingStore(marketingConsent: marketingConsent, tempUser: tempUser)
            return UIHostingController(rootView: NicknameSettingView(store: store).environment(self))
            
        case .signupFailed:
            return UIHostingController(
                rootView: ErrorSheetView(
                   title: "오류가 발생했어요!",
                   message: "잠시 후 다시 시도해주세요",
                   confirmTitle: "로그인으로 돌아가기"
               ) { [weak self] in
                   self?.dismiss(completion: { self?.popToRoot() })
               }
            )
            
        case .safari(let url):
            let safariView = SafariView(url: url) { [weak self] in
                self?.dismiss()
            }.ignoresSafeArea()
            return UIHostingController(rootView: safariView)
        }
    }

    func completeLogin(with nickname: String) {
        onLoginCompleted(nickname)
    }

    func completeSignup(with nickname: String) {
        onSignupCompleted(nickname)
    }
}
