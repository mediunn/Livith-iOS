//
//  NicknameSettingView.swift
//  LoginFeature
//
//  Created by 김진웅 on 11/5/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import SwiftUI

import Domain
import LivithDesignSystem
import NicknameEditFeature

struct NicknameSettingView: View {
    @Environment(\.loginCoordinator) private var coordinator

    @State private var isSignupFailureModalPresented: Bool = false
    @State private var signupFailureMessage: String = ""

    private let marketingConsent: Bool
    private let tempUser: TempUser

    init(marketingConsent: Bool, tempUser: TempUser) {
        self.marketingConsent = marketingConsent
        self.tempUser = tempUser
    }

    var body: some View {
        // TODO: - 회원가입 API 연결 취향 설정 이후로 빼기
        NicknameEditView(
            config: .signup(marketingConsent: marketingConsent, tempUser: tempUser),
            onDismiss: { coordinator?.pop() },
            onSubmitSuccess: { nickname in
                coordinator?.completeSignup(with: nickname)
            },
            onSubmitFailure: { message in
                signupFailureMessage = message
                isSignupFailureModalPresented = true
            }
        )
        .crossDissolve(isPresented: $isSignupFailureModalPresented, dismissOnTapOutside: false) {
            LivithModal(
                type: .error(title: "오류가 발생했어요!", message: signupFailureMessage),
                confirmTitle: "로그인으로 돌아가기",
                onConfirm: {
                    isSignupFailureModalPresented = false
                    Task { @MainActor in
                        try? await Task.sleep(for: .seconds(0.25))
                        coordinator?.popToRoot()
                    }
                }
            )
        }
    }
}
