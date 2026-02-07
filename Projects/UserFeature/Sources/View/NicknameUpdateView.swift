//
//  NicknameUpdateView.swift
//  UserFeature
//
//  Created by Youjin Lee on 12/9/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import SwiftUI

import LivithDesignSystem
import NicknameEditFeature

struct NicknameUpdateView: View {

    // MARK: - Property

    @State private var showFailureToast: Bool = false
    @State private var toastMessage: String = ""

    @Environment(\.userCoordinator) private var coordinator

    var body: some View {
        NicknameEditView(
            config: .update,
            onDismiss: { coordinator?.pop() },
            onSubmitSuccess: { _ in
                coordinator?.pop()
            },
            onSubmitFailure: { _ in
                toastMessage = "닉네임 변경에 실패했어요"
                withAnimation { showFailureToast = true }
            }
        )
        .livithToast(
            isPresented: $showFailureToast,
            type: .failure,
            message: toastMessage
        )
    }
}
