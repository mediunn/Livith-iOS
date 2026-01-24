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
import NicknameEdit

struct NicknameSettingView: View {
    @Environment(\.loginCoordinator) private var coordinator

    @State private var showErrorToast: Bool = false
    @State private var errorMessage: String = ""

    private let marketingConsent: Bool
    private let tempUser: TempUser

    init(marketingConsent: Bool, tempUser: TempUser) {
        self.marketingConsent = marketingConsent
        self.tempUser = tempUser
    }

    var body: some View {
        NicknameEditView(
            config: .signup(marketingConsent: marketingConsent, tempUser: tempUser),
            onDismiss: { coordinator?.pop() },
            onSubmitSuccess: { nickname in
                coordinator?.completeSignup(with: nickname)
            },
            onSubmitFailure: { message in
                errorMessage = message
                withAnimation { showErrorToast = true }
            }
        )
        .livithToast(
            isPresented: $showErrorToast,
            type: .failure,
            message: errorMessage,
            duration: 2,
            position: .safeAreaTop
        )
    }
}
