//
//  LivithDangerModal.swift
//  DSKit
//
//  Created by Youjin Lee on 1/6/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import SwiftUI

// MARK: - Modal Type

public enum LivithDangerModalType {
    case confirm(onConfirm: () -> Void)
    case report(onConfirm: (String) -> Void)
}

// MARK: - LivithDangerModal

public struct LivithDangerModal: View {

    // MARK: - Constants

    private enum Constants {
        static let maxLength = 200
        static let placeholder = "신고 사유를 작성해주세요"
    }

    // MARK: - Property

    private let message: String
    private let confirmTitle: String
    private let cancelTitle: String
    private let type: LivithDangerModalType
    private let onCancel: () -> Void

    @State private var text: String = ""
    @State private var isOverLimit: Bool = false
    @State private var keyboardHeight: CGFloat = 0
    @FocusState private var isFocused: Bool

    private var isConfirmEnabled: Bool {
        !isOverLimit
    }

    private var isReportType: Bool {
        if case .report = type { return true }
        return false
    }

    // MARK: - Initializer

    public init(
        message: String,
        confirmTitle: String,
        cancelTitle: String,
        type: LivithDangerModalType,
        onCancel: @escaping () -> Void
    ) {
        self.message = message
        self.confirmTitle = confirmTitle
        self.cancelTitle = cancelTitle
        self.type = type
        self.onCancel = onCancel
    }

    // MARK: - Body

    public var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color(hex: "14171B", opacity: 0.9)
                    .ignoresSafeArea()
                    .onTapGesture {
                        if isReportType {
                            isFocused = false
                        } else {
                            onCancel()
                        }
                    }

                dialogContent
                    .padding(.horizontal, 24)
                    .offset(y: isReportType && keyboardHeight > 0 ? -(keyboardHeight / 2) : 0)
                    .animation(.easeInOut(duration: 0.25), value: keyboardHeight)

                if isReportType && isOverLimit {
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
            if isReportType {
                keyboardHeight = KeyboardHeightObserver.shared.height
            }
        }
        .onReceive(KeyboardHeightObserver.shared.$height) { height in
            if isReportType {
                keyboardHeight = height
            }
        }
    }

    private var dialogContent: some View {
        VStack(alignment: .center, spacing: 20) {
            headerSection

            if isReportType {
                textInputSection
            }

            buttonSection
        }
        .padding(.all, 16)
        .background(Color.livithColor(.white100))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - Header Section

private extension LivithDangerModal {
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

private extension LivithDangerModal {
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

private extension LivithDangerModal {
    var buttonSection: some View {
        HStack(spacing: 12) {
            confirmButton
            cancelButton
        }
    }

    var confirmButton: some View {
        Button {
            switch type {
            case .confirm(let onConfirm):
                onConfirm()
            case .report(let onConfirm):
                onConfirm(text)
            }
        } label: {
            Text(confirmTitle)
                .notosans(.body3Medium)
                .foregroundStyle(
                    isReportType && !isConfirmEnabled
                        ? Color.livithColor(.black50)
                        : Color.livithColor(.caution100)
                )
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .background(Color.livithColor(.black5))
                .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .disabled(isReportType && !isConfirmEnabled)
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

// MARK: - Preview

#Preview("Confirm") {
    LivithDangerModal(
        message: "정말 로그아웃 하시겠어요?",
        confirmTitle: "로그아웃 할래요",
        cancelTitle: "취소할래요",
        type: .confirm(onConfirm: { }),
        onCancel: { }
    )
}

#Preview("Report") {
    LivithDangerModal(
        message: "댓글을 신고하시겠어요?",
        confirmTitle: "신고할래요",
        cancelTitle: "잘못 눌렀어요",
        type: .report(onConfirm: { _ in }),
        onCancel: { }
    )
}
