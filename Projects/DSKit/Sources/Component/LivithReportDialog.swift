//
//  LivithReportDialog.swift
//  DSKit
//
//  Created by Youjin Lee on 12/31/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import SwiftUI

public struct LivithReportDialog: View {

    // MARK: - Constants

    private enum Constants {
        static let maxLength = 200
        static let placeholder = "신고 사유를 작성해주세요"
    }

    // MARK: - Property

    private let message: String
    private let confirmTitle: String
    private let cancelTitle: String
    private let onConfirm: (String) -> Void
    private let onCancel: () -> Void

    @State private var text: String = ""
    @State private var isOverLimit: Bool = false
    @State private var keyboardHeight: CGFloat = 0
    @FocusState private var isFocused: Bool

    private var isConfirmEnabled: Bool {
        !isOverLimit
    }

    // MARK: - Initializer

    public init(
        message: String,
        confirmTitle: String,
        cancelTitle: String,
        onConfirm: @escaping (String) -> Void,
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
        GeometryReader { geometry in
            ZStack {
                Color(hex: "14171B", opacity: 0.9)
                    .ignoresSafeArea()
                    .onTapGesture {
                        isFocused = false
                    }

                dialogContent
                    .padding(.horizontal, 24)
                    .offset(y: keyboardHeight > 0 ? -(keyboardHeight / 2) : 0)
                    .animation(.easeInOut(duration: 0.25), value: keyboardHeight)

                if isOverLimit {
                    LivithToast(type: .failure, message: "200자를 초과했어요")
                        .position(
                            x: geometry.size.width / 2,
                            y: geometry.size.height - keyboardHeight - 20 - 27
                        )
                }
            }
        }
        .ignoresSafeArea(.keyboard)
        .onAppear {
            keyboardHeight = KeyboardHeightObserver.shared.height
        }
        .onReceive(KeyboardHeightObserver.shared.$height) { height in
            keyboardHeight = height
        }
    }

    private var dialogContent: some View {
        VStack(alignment: .center, spacing: 20) {
            headerSection

            textInputSection

            buttonSection
        }
        .padding(.all, 16)
        .background(Color.livithColor(.white100))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - Header Section

private extension LivithReportDialog {
    var headerSection: some View {
        VStack(alignment: .center, spacing: 10) {
            Image.livithIcon(.cautionFill)
                .resizable()
                .frame(width: 44, height: 44)

            Text(message)
                .notosans(.body2Medium)
                .foregroundStyle(Color(hex: "363636"))
        }
    }
}

// MARK: - Text Input Section

private extension LivithReportDialog {
    var textInputSection: some View {
        ZStack(alignment: .bottomTrailing) {
            VStack {
                TextField(
                    "",
                    text: $text,
                    prompt: Text(Constants.placeholder)
                        .foregroundStyle(Color.livithColor(.black50)),
                    axis: .vertical
                )
                .notosans(.body3Medium)
                .foregroundStyle(Color.livithColor(.black100))
                .lineLimit(6)
                .focused($isFocused)
                .onChange(of: text) { _, newValue in
                    isOverLimit = newValue.count > Constants.maxLength
                }

                Spacer()
            }
            .padding(14)
            .frame(height: 172)
            .background(Color.livithColor(.black5))
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .overlay(alignment: .top) {
                if text.components(separatedBy: "\n").count > 5 || text.count > 130 {
                    LinearGradient(
                        colors: [Color.livithColor(.black5), Color.livithColor(.black5).opacity(0)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .frame(height: 44)
                }
            }
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isFocused ? Color.livithColor(.black30) : Color.clear, lineWidth: 1)
            )

            Text("\(text.count)/\(Constants.maxLength)")
                .notosans(.body4Medium)
                .padding(12)
                .foregroundStyle(
                    isOverLimit
                        ? Color.livithColor(.caution100)
                        : Color.livithColor(.black50)
                )
        }
    }
}

// MARK: - Button Section

private extension LivithReportDialog {
    var buttonSection: some View {
        HStack(spacing: 12) {
            dialogButton(
                title: confirmTitle,
                textColor: isConfirmEnabled ? .livithColor(.caution100) : .livithColor(.black50),
                backgroundColor: .livithColor(.black5),
                isEnabled: isConfirmEnabled
            ) {
                onConfirm(text)
            }

            dialogButton(
                title: cancelTitle,
                textColor: .livithColor(.white100),
                backgroundColor: .livithColor(.black80)
            ) {
                onCancel()
            }
        }
    }

    func dialogButton(
        title: String,
        textColor: Color,
        backgroundColor: Color,
        isEnabled: Bool = true,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Text(title)
                .notosans(.body3Medium)
                .foregroundStyle(textColor)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .background(backgroundColor)
                .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .disabled(!isEnabled)
    }
}

// MARK: - Preview

#Preview {
    LivithReportDialog(
        message: "댓글을 신고하시겠어요?",
        confirmTitle: "신고할래요",
        cancelTitle: "잘못 눌렀어요",
        onConfirm: { _ in },
        onCancel: { }
    )
}
