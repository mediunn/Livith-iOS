//
//  NicknameEditView.swift
//  NicknameEditFeature
//
//  Created by Youjin Lee on 1/23/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import SwiftUI

import LivithDesignSystem

public struct NicknameEditView: View {

    // MARK: - Property

    private let maxNicknameLength = 10

    @StateObject private var store: NicknameEditStore
    @State private var isNicknameFocused: Bool = false

    private let config: NicknameEditConfig
    private let onDismiss: () -> Void
    private let onSubmitSuccess: (String) -> Void
    private let onSubmitFailure: ((String) -> Void)?

    // MARK: - Lifecycle

    public init(
        config: NicknameEditConfig,
        onDismiss: @escaping () -> Void,
        onSubmitSuccess: @escaping (String) -> Void,
        onSubmitFailure: ((String) -> Void)? = nil
    ) {
        self._store = StateObject(wrappedValue: NicknameEditStore(config: config))
        self.config = config
        self.onDismiss = onDismiss
        self.onSubmitSuccess = onSubmitSuccess
        self.onSubmitFailure = onSubmitFailure
    }

    public var body: some View {
        ZStack {
            Color.livithColor(.black100)
                .ignoresSafeArea()
                .onTapGesture {
                    isNicknameFocused = false
                }

            VStack(alignment: .leading, spacing: 0) {
                navigationBar

                if config.showStepIndicator {
                    stepIndicator
                        .padding(.top, 10)
                        .padding(.horizontal, 16)
                }

                title
                    .padding(.top, 32)
                    .padding(.horizontal, 16)

                nicknameInputSection
                    .padding(.top, 20)
                    .padding(.horizontal, 16)

                nicknameStatus
                    .padding(.top, 8)
                    .padding(.horizontal, 16)

                Spacer()

                submitButton
                    .padding(.bottom, 50)
                    .padding(.horizontal, 16)
            }
        }
        .ignoresSafeArea(.all, edges: .bottom)
        .onChange(of: store.state.submitResult) { _, result in
            switch result {
            case .idle:
                break
            case .success:
                onSubmitSuccess(store.nickname)
            case .failure(let message):
                onSubmitFailure?(message)
            }
        }
    }
}

// MARK: - UIComponents

private extension NicknameEditView {
    var navigationBar: some View {
        LivithNavigationView(
            type: .back(title: config.navigationTitle, onBack: onDismiss)
        )
    }

    var stepIndicator: some View {
        StepIndicatorView(currentStep: 2, totalSteps: 4)
    }

    var title: some View {
        Text(config.title)
            .notosans(.body1Semibold)
            .foregroundStyle(Color.livithColor(.white100))
    }

    var nicknameInputSection: some View {
        HStack(spacing: 12) {
            nicknameTextField

            duplicateButton
        }
    }

    var nicknameTextField: some View {
        LivithTextField(
            text: nicknameBinding,
            isFocused: $isNicknameFocused,
            type: .text(maxLength: maxNicknameLength),
            placeholder: NicknameEditLiterals.placeholder,
            onSubmit: { isNicknameFocused = false },
            onClear: { store.updateNickname("") }
        )
        .disabled(store.validationState == .checking)
    }

    var duplicateButton: some View {
        LivithConfirmButton(duplicateButtonText, variant: .dark) {
            isNicknameFocused = false
            store.checkDuplicate()
        }
        .disabled(!isDuplicateButtonEnabled)
    }

    var nicknameStatus: some View {
        Text(statusMessage)
            .notosans(.caption1Regular)
            .foregroundColor(statusMessageColor)
    }

    var submitButton: some View {
        LivithButton(
            config.submitButtonText,
            variant: .primary,
            isLoading: store.isSubmitting
        ) {
            store.submit()
        }
        .disabled(!isSubmitButtonEnabled || store.isSubmitting)
    }
}

// MARK: - Helpers

private extension NicknameEditView {
    var duplicateButtonText: String {
        store.validationState == .available ? NicknameEditLiterals.checkCompleted : NicknameEditLiterals.checkDuplicate
    }

    var isDuplicateButtonEnabled: Bool {
        store.validationState == .valid
    }

    var statusMessage: String {
        switch store.validationState {
        case .idle:
            return NicknameEditLiterals.statusIdle
        case .valid, .checking:
            return ""
        case .invalid:
            return NicknameEditLiterals.statusInvalid
        case .available:
            return NicknameEditLiterals.statusAvailable
        case .duplicate:
            return NicknameEditLiterals.statusDuplicate
        }
    }

    var statusMessageColor: Color {
        switch store.validationState {
        case .idle, .valid, .checking:
            return .livithColor(.black50)
        case .invalid, .duplicate:
            return .livithColor(.translation)
        case .available:
            return .livithColor(.yellow30)
        }
    }

    var isSubmitButtonEnabled: Bool {
        store.validationState == .available
    }

    var nicknameBinding: Binding<String> {
        Binding {
            store.nickname
        } set: { newValue in
            guard store.validationState != .checking else { return }
            store.updateNickname(newValue)
        }
    }
}

// MARK: - Literals

private enum NicknameEditLiterals {
    static let placeholder = "예시) 홍길동"
    static let checkDuplicate = "중복확인"
    static let checkCompleted = "확인완료"
    static let statusIdle = "10자리 이내, 문자/숫자로 입력 가능해요"
    static let statusInvalid = "닉네임 형식이 올바르지 않아요"
    static let statusAvailable = "사용할 수 있는 닉네임이에요!"
    static let statusDuplicate = "이미 존재하는 닉네임이에요"
}
