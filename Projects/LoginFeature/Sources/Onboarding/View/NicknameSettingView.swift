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

    private let builder: SignupBuilder

    init(builder: SignupBuilder) {
        self.builder = builder
    }

    var body: some View {
        NicknameEditView(config: .signup) {
            coordinator?.pop()
        } onSubmitSuccess: { nickname in
            coordinator?.push(to: .preferredGenre(builder.withNickname(nickname)))
        }
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
