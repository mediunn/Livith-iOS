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
    @StateObject private var store = LoginStore()
    @Environment(\.loginCoordinator) private var coordinator
    
    @State private var isForbiddenModalPresented = false
    
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
            message: store.state.errorMessage
        )
        .crossDissolve(isPresented: $isForbiddenModalPresented, dismissOnTapOutside: false) {
            LivithModal(
                type: .error(
                    title: "탈퇴 후 7일이 지나지 않았어요",
                    message: "7일이 지난 후 다시 시도해주세요"
                ),
                confirmTitle: "로그인으로 돌아가기",
                onConfirm: {
                    isForbiddenModalPresented = false
                }
            )
        }
        .onChange(of: store.state.status) { oldValue, newValue in
            guard let loginStatus = newValue else { return }
            handleLoginSuccess(loginStatus)
        }
    }
    
    private func handleLoginSuccess(_ status: LoginStatus) {
        switch status {
        case .existingUser:
            coordinator?.completeLogin()
        case .newUser(let tempUser):
            coordinator?.push(to: .terms(tempUser))
        case .forbidden:
            isForbiddenModalPresented = true
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
            LivithCalloutView(store.state.calloutMessage.text, highlight: store.state.calloutMessage.targetText)
                .frame(width: 272, height: 40)

            VStack(spacing: 12) {
                LivithLoginButton(provider: .kakao) {
                    store.send(.kakaoLogin)
                }

                LivithLoginButton(provider: .apple) {
                    store.send(.appleLogin)
                }
            }
        }
        .padding(.top, 40)
        .padding(.horizontal, 16)
        .padding(.bottom, 100)
    }
}


#Preview {
    LoginView()
}
