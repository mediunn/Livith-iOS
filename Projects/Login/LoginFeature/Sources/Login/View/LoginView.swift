//
//  LoginView.swift
//  LoginFeature
//
//  Created by 김진웅 on 12/3/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import SwiftUI

import DSKit
import LoginDomain

struct LoginView: View {
    @StateObject private var store = LoginStore()
    @Environment(\.loginCoordinator) private var coordinator
    
    var body: some View {
        ZStack {
            Color.livithColor(.black100)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                header
                
                Spacer()
                
                loginButtons
            }
        }
        .livithToast(
            isPresented: Binding(
                get: { !store.state.errorMessage.isEmpty },
                set: { _ in store.send(.setErrorMessage("")) }
            ),
            type: .failure,
            message: store.state.errorMessage,
            duration: 2,
            position: .safeAreaTop
        )
        .onChange(of: store.state.status) { oldValue, newValue in
            guard let loginStatus = newValue else { return }
            handleLoginSuccess(loginStatus)
        }
    }
    
    private func handleLoginSuccess(_ status: LoginStatus) {
        switch status {
        case .existingUser(let nickname):
            coordinator?.completeLogin(with: nickname)
        case .newUser(let tempUser):
            coordinator?.push(to: .terms(tempUser))
        case .forbidden:
            coordinator?
                .present(to: .loginForbidden, presentationStyle: .overFullScreen, transitionStyle: .crossDissolve)
        }
    }
}

// MARK: - UIComponents

private extension LoginView {
    var header: some View {
        ZStack(alignment: .top) {
            LinearGradient(
                gradient: Gradient(colors: [Color(hex: "#2f3745", opacity: 0.97), Color(hex: "#14171b")]),
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 297)
            .edgesIgnoringSafeArea([.top, .horizontal])
            
            Image.livithImage(.livithLogo)
                .resizable()
                .frame(width: 204, height: 52)
                .padding(.top, 200)
        }
    }
    
    var loginButtons: some View {
        VStack(spacing: 20) {
            CalloutChipView(text: store.state.calloutMessage.text, targetText: store.state.calloutMessage.targetText)
                .frame(width: 272, height: 36)
            
            VStack(spacing: 12) {
                LoginButton(
                    title: Literals.kakaoLoginTitle,
                    backgroundColor: Color(hex: "#fce64a"),
                    textColor: Color(hex: "#14171b"),
                    icon: Image.livithIcon(.kakao)
                ) {
                    store.send(.kakaoLogin)
                }
                
                LoginButton(
                    title: Literals.appleLoginTitle,
                    backgroundColor: Color(hex: "#222831"),
                    textColor: Color(hex: "#f2f4f6"),
                    icon: Image.livithIcon(.apple)
                ) {
                    store.send(.appleLogin)
                }
            }
        }
        .padding(.top, 40)
        .padding(.horizontal, 16)
        .padding(.bottom, 100)
    }
}

// MARK: - Literals

private extension LoginView {
    enum Literals {
        static let kakaoLoginTitle = "카카오로 계속하기"
        static let appleLoginTitle = "Apple로 계속하기"
        static let errorAlertTitle = "알림"
        static let confirmButtonTitle = "확인"
    }
}

#Preview {
    LoginView()
}
