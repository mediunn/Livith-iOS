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
    @EnvironmentObject private var router: LoginRouter

    @State private var isSignupFailureModalPresented: Bool = false
    @State private var signupFailureMessage: String = ""

    private let session: SignupSession

    init(session: SignupSession) {
        self.session = session
    }

    var body: some View {
        NicknameEditView(config: .signup) {
            router.pop()
        } onSubmitSuccess: { nickname in
            guard let nickname = try? Nickname(nickname) else { return }
            var updatedSession = session
            updatedSession.changeNickname(to: nickname)
            updatedSession.confirmNickname(nickname)
            router.push(.preferredGenre(updatedSession))
        }
        .crossDissolve(isPresented: $isSignupFailureModalPresented, dismissOnTapOutside: false) {
            LivithModal(
                type: .error(title: "오류가 발생했어요!", message: signupFailureMessage),
                confirmTitle: "로그인으로 돌아가기",
                onConfirm: {
                    isSignupFailureModalPresented = false
                    Task { @MainActor in
                        try? await Task.sleep(for: .seconds(0.25))
                        router.popToRoot()
                    }
                }
            )
        }
    }
}
