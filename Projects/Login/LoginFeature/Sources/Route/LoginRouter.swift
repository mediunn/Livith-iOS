//
//  LoginRouter.swift
//  LoginFeature
//
//  Created by 김진웅 on 12/8/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import Foundation
import SwiftUI

import Router
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
            
        case .loginForbidden:
            return AnyView(
                ErrorSheetView(
                    title: "탈퇴 후 7일이 지나지 않았어요",
                    message: "7일이 지난 후 다시 시도해주세요"
                ) { [weak self] in
                    self?.dismissFullScreen()
                }
            )
            
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
            return AnyView(
                ErrorSheetView(
                    title: "오류가 발생했어요!",
                    message: "잠시 후 다시 시도해주세요",
                    confirmTitle: "로그인으로 돌아가기"
                ) { [weak self] in
                    self?.popToRoot()
                    self?.dismissFullScreen()
                }
            )
            
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
