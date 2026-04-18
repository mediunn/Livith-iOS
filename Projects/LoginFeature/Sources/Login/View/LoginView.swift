//
//  LoginView.swift
//  LoginFeature
//
//  Created by 김진웅 on 12/3/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import SwiftUI

import LivithDesignSystem
import Domain

struct LoginView: View {
    
    // MARK: - Constants
    
    private enum Constants {
        static let contentBottomPadding: CGFloat = 16
        static let calloutWidth: CGFloat = 272
    }
    
    private enum Literals {
        static let forbiddenTitle = "탈퇴 후 7일이 지나지 않았어요"
        static let forbiddenMessage = "7일이 지난 후 다시 시도해주세요"
        static let forbiddenConfirmTitle = "로그인으로 돌아가기"
    }
    
    @StateObject private var store = LoginStore()
    @Environment(\.loginCoordinator) private var coordinator
    
    var body: some View {
        contentView
            .background(
                Color.livithColor(.black100)
                    .ignoresSafeArea()
            )
            .ignoresSafeArea(.all, edges: .top)
            .livithToast(
                isPresented: errorToastBinding,
                type: .failure,
                message: store.state.errorMessage
            )
            .crossDissolve(isPresented: forbiddenModalBinding) {
                forbiddenModal
            }
            .onChange(of: store.state.status) { _, newValue in
                guard let loginStatus = newValue else { return }
                handleLoginSuccess(loginStatus)
            }
    }
}

// MARK: - Subviews

private extension LoginView {
    var contentView: some View {
        VStack(spacing: 0) {
            LoginBannerSectionView()
            
            Spacer(minLength: 16)
            
            loginButtons
        }
    }
    
    var forbiddenModal: some View {
        LivithModal(
            type: .error(
                title: Literals.forbiddenTitle,
                message: Literals.forbiddenMessage
            ),
            confirmTitle: Literals.forbiddenConfirmTitle,
            onConfirm: dismissForbiddenModal
        )
    }
    
    var loginButtons: some View {
        VStack(spacing: 20) {
            LivithCalloutView(
                store.state.calloutMessage.text,
                highlight: store.state.calloutMessage.targetText,
                widthMode: .fill
            )
            .frame(width: Constants.calloutWidth)
            
            VStack(spacing: 12) {
                LivithLoginButton(provider: .kakao) {
                    store.send(.kakaoLogin)
                }
                
                LivithLoginButton(provider: .apple) {
                    store.send(.appleLogin)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.bottom, Constants.contentBottomPadding)
    }
}

// MARK: - Helpers

private extension LoginView {
    var errorToastBinding: Binding<Bool> {
        Binding(
            get: { !store.state.errorMessage.isEmpty },
            set: handleErrorToastBinding
        )
    }
    
    var forbiddenModalBinding: Binding<Bool> {
        Binding(
            get: { store.state.isForbiddenModalPresented },
            set: setForbiddenModalPresented
        )
    }
    
    func handleErrorToastBinding(_ isPresented: Bool) {
        if !isPresented {
            store.send(.setErrorMessage(""))
        }
    }
    
    func dismissForbiddenModal() {
        store.send(.setForbiddenModalPresented(false))
    }
    
    func setForbiddenModalPresented(_ isPresented: Bool) {
        store.send(.setForbiddenModalPresented(isPresented))
    }
    
    func handleLoginSuccess(_ status: LoginStatus) {
        switch status {
        case .existingUser:
            coordinator?.completeLogin()
        case .newUser(let tempUser):
            coordinator?.push(to: .terms(tempUser))
        }
    }
}
