//
//  LivithDangerModal.swift
//  LivithDesignSystem
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
    @State private var isFocused: Bool = false

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
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
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
                .multilineTextAlignment(.center)
        }
    }
}

// MARK: - Text Input Section

private extension LivithDangerModal {
    var textInputSection: some View {
        LivithTextView(
            text: $text,
            isFocused: $isFocused,
            type: .report(maxLength: Constants.maxLength),
            placeholder: Constants.placeholder,
            height: 172
        )
        .onChange(of: text) { _, newValue in
            isOverLimit = newValue.count > Constants.maxLength
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
        DangerModalButton(title: confirmTitle, role: .confirm, cornerRadius: 8) {
            switch type {
            case .confirm(let onConfirm):
                onConfirm()
            case .report(let onConfirm):
                onConfirm(text)
            }
        }
        .disabled(isReportType && !isConfirmEnabled)
    }

    var cancelButton: some View {
        DangerModalButton(title: cancelTitle, role: .cancel, cornerRadius: 8) {
            onCancel()
        }
    }
}

// MARK: - Local Button

private struct DangerModalButton: View {
    let title: String
    let role: DangerModalButtonRole
    let cornerRadius: CGFloat
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .notosans(.body3Semibold)
                .foregroundStyle(role.enabledForeground)
                .frame(maxWidth: .infinity)
                .frame(height: 52)
        }
        .buttonStyle(DangerModalButtonStyle(role: role, cornerRadius: cornerRadius))
    }
}

private enum DangerModalButtonRole {
    case confirm
    case cancel

    var enabledBackground: Color {
        switch self {
        case .confirm:
            return .livithColor(.black5)
        case .cancel:
            return .livithColor(.black80)
        }
    }

    var pressedBackground: Color {
        switch self {
        case .confirm:
            return .livithColor(.black30)
        case .cancel:
            return .livithColor(.black50)
        }
    }

    var enabledForeground: Color {
        switch self {
        case .confirm:
            return .livithColor(.caution100)
        case .cancel:
            return .livithColor(.white100)
        }
    }
}

private struct DangerModalButtonStyle: ButtonStyle {
    let role: DangerModalButtonRole
    let cornerRadius: CGFloat

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(backgroundColor(isPressed: configuration.isPressed))
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }

    private func backgroundColor(isPressed: Bool) -> Color {
        return isPressed ? role.pressedBackground : role.enabledBackground
    }
}

// MARK: - Preview

#Preview("Danger Modals") {
    LivithDangerModalPreviewContainer()
}

private struct LivithDangerModalPreviewContainer: View {
    @State private var isConfirmPresented = false
    @State private var isReportPresented = false

    var body: some View {
        ZStack {
            Color.livithColor(.black100).ignoresSafeArea()

            VStack(spacing: 16) {
                Button("확인 모달 보기") {
                    isConfirmPresented = true
                }
                .buttonStyle(.borderedProminent)

                Button("신고 모달 보기") {
                    isReportPresented = true
                }
                .buttonStyle(.bordered)
            }
        }
        .crossDissolve(isPresented: $isConfirmPresented, dismissOnTapOutside: true) {
            LivithDangerModal(
                message: "정말 로그아웃 하시겠어요?",
                confirmTitle: "로그아웃 할래요",
                cancelTitle: "취소할래요",
                type: .confirm(onConfirm: { isConfirmPresented = false }),
                onCancel: { isConfirmPresented = false }
            )
        }
        .crossDissolve(isPresented: $isReportPresented, dismissOnTapOutside: true) {
            LivithDangerModal(
                message: "댓글을 신고하시겠어요?",
                confirmTitle: "신고할래요",
                cancelTitle: "잘못 눌렀어요",
                type: .report(onConfirm: { _ in isReportPresented = false }),
                onCancel: { isReportPresented = false }
            )
        }
    }
}
