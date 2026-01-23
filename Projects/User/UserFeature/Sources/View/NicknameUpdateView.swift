//
//  NicknameUpdateView.swift
//  UserFeature
//
//  Created by Youjin Lee on 12/9/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import SwiftUI

import LivithDesignSystem
import NicknameEdit

public struct NicknameUpdateView: View {

    // MARK: - Property

    @State private var showFailureToast: Bool = false
    @State private var toastMessage: String = ""

    private let onDismiss: (() -> Void)?
    private let onSuccess: ((String) -> Void)?

    // MARK: - LifeCycle

    public init(
        onDismiss: (() -> Void)? = nil,
        onSuccess: ((String) -> Void)? = nil
    ) {
        self.onDismiss = onDismiss
        self.onSuccess = onSuccess
    }

    public var body: some View {
        NicknameEditView(
            config: .update,
            onDismiss: { onDismiss?() },
            onSubmitSuccess: { nickname in
                onSuccess?(nickname)
            },
            onSubmitFailure: { _ in
                toastMessage = "닉네임 변경에 실패했어요"
                withAnimation { showFailureToast = true }
            }
        )
        .livithToast(
            isPresented: $showFailureToast,
            type: .failure,
            message: toastMessage,
            position: .safeAreaTop
        )
    }
}
