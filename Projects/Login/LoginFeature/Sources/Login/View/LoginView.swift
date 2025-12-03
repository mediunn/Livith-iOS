//
//  LoginView.swift
//  LoginFeature
//
//  Created by 김진웅 on 12/3/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import SwiftUI

import DSKit

struct LoginView: View {
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
            CalloutChipView(text: Literals.greetingMessage, targetText: "모든 서비스 이용")
                .frame(width: 273, height: 48)
            
            VStack(spacing: 12) {
                LoginButton(
                    title: Literals.kakaoLoginTitle,
                    backgroundColor: Color(hex: "#fce64a"),
                    textColor: Color(hex: "#14171b"),
                    icon: Image.livithIcon(.kakao)
                ) {

                    // TODO: 카카오 로그인 버튼 액션 구현
                }
                
                LoginButton(
                    title: Literals.appleLoginTitle,
                    backgroundColor: Color(hex: "#222831"),
                    textColor: Color(hex: "#f2f4f6"),
                    icon: Image.livithIcon(.apple)
                ) {
                    
                    // TODO: Apple 로그인 버튼 액션 구현
                    
                }
            }
        }
        .padding(.top, 40)
        .padding(.horizontal, 16)
        .padding(.bottom, 100)
    }
}

// MARK: - Helpers

private extension LoginView {
    var window: UIWindow? {
        UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first?.windows
            .first(where: { $0.isKeyWindow })
    }
}

// MARK: - Literals

private extension LoginView {
    enum Literals {
        static let kakaoLoginTitle = "카카오로 계속하기"
        static let appleLoginTitle = "Apple로 계속하기"
        static let greetingMessage = "회원가입하고 모든 서비스 이용해보세요!"
        static let kakaoLoginMessage = "카카오로 최근에 로그인 했어요"
        static let appleLoginMessage = "Apple로 최근에 로그인 했어요"
    }
}

#Preview {
    LoginView()
}
