//
//  LivithConfirmDialog.swift
//  DSKit
//
//  Created by Youjin Lee on 12/12/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import SwiftUI

public struct LivithConfirmDialog: View {

    // MARK: - Property

    private let message: String
    private let confirmTitle: String
    private let cancelTitle: String
    private let onConfirm: () -> Void
    private let onCancel: () -> Void

    // MARK: - LifeCycle

    public init(
        message: String,
        confirmTitle: String,
        cancelTitle: String,
        onConfirm: @escaping () -> Void,
        onCancel: @escaping () -> Void
    ) {
        self.message = message
        self.confirmTitle = confirmTitle
        self.cancelTitle = cancelTitle
        self.onConfirm = onConfirm
        self.onCancel = onCancel
    }

    // MARK: - Body

    public var body: some View {
        ZStack {
            Color(hex: "14171B", opacity: 0.9)
                .ignoresSafeArea()
                .onTapGesture {
                    onCancel()
                }

            dialogContent
                .padding(.horizontal, 24)
        }
    }

    private var dialogContent: some View {
        VStack(alignment: .center, spacing: 20) {
            VStack(alignment: .center, spacing: 10) {
                Image.livithIcon(.cautionFill)
                    .resizable()
                    .frame(width: 44, height: 44)

                Text(message)
                    .notosans(.body2Medium)
                    .foregroundStyle(Color(hex: "363636"))
            }

            HStack(spacing: 12) {
                confirmButton
                cancelButton
            }
        }
        .padding(.all, 16)
        .background(Color.livithColor(.white100))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - UIComponents

private extension LivithConfirmDialog {
    var confirmButton: some View {
        Button(action: onConfirm) {
            Text(confirmTitle)
                .notosans(.body3Medium)
                .foregroundStyle(Color.livithColor(.caution100))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .background(Color.livithColor(.black5))
                .clipShape(RoundedRectangle(cornerRadius: 8))
        }
    }

    var cancelButton: some View {
        Button(action: onCancel) {
            Text(cancelTitle)
                .notosans(.body3Medium)
                .foregroundStyle(Color.livithColor(.white100))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .background(Color.livithColor(.black80))
                .clipShape(RoundedRectangle(cornerRadius: 8))
        }
    }
}

#Preview {
    LivithConfirmDialog(
        message: "정말 로그아웃 하시겠어요?",
        confirmTitle: "로그아웃 할래요",
        cancelTitle: "취소할래요",
        onConfirm: { },
        onCancel: { }
    )
}
