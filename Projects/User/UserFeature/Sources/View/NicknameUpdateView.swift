//
//  NicknameUpdateView.swift
//  LoginFeature
//
//  Created by Youjin Lee on 12/9/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import SwiftUI

import LivithDesignSystem

struct NicknameUpdateView: View {
    
    // MARK: - Property

    private let maxNicknameLength = 10

    @State private var isNicknameFocused: Bool = false
    @State private var showFailureToast: Bool = false
    @ObservedObject private var store: NicknameUpdateStore

    var onDismiss: (() -> Void)?
    var onSuccess: ((String) -> Void)?

    // MARK: - LifeCycle

    init(
        store: NicknameUpdateStore,
        onDismiss: (() -> Void)? = nil,
        onSuccess: ((String) -> Void)? = nil
    ) {
        self._store = ObservedObject(wrappedValue: store)
        self.onDismiss = onDismiss
        self.onSuccess = onSuccess
    }
    
    var body: some View {
        ZStack {
            Color.livithColor(.black100)
                .ignoresSafeArea()
                .onTapGesture {
                    isNicknameFocused = false
                }

            VStack(alignment: .leading, spacing: 0) {
                navigationBar

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

                updateButton
                    .padding(.bottom, 50)
                    .padding(.horizontal, 16)
            }
        }
        .ignoresSafeArea(.all, edges: .bottom)
        .livithToast(
            isPresented: $showFailureToast,
            type: .failure,
            message: Literals.toastFailure,
            position: .safeAreaTop
        )
        .onChange(of: store.state.updateResult) { _, result in
            switch result {
            case .idle:
                withAnimation { showFailureToast = false }
            case .success:
                onSuccess?(store.state.nickname)
            case .failure:
                withAnimation { showFailureToast = true }
            }
        }
    }
}

// MARK: - UIComponents

private extension NicknameUpdateView {
    var navigationBar: some View {
        LivithNavigationView(
            type: .back(title: Literals.navigationTitle, onBack: { onDismiss?() })
        )
    }
    
    var stepIndicator: some View {
        HStack(spacing: 4) {
            Capsule()
                .fill(Color.livithColor(.yellow30))
                .frame(height: 4)
            
            Capsule()
                .fill(Color.livithColor(.yellow30))
                .frame(height: 4)
        }
    }
    
    var title: some View {
        Text(Literals.title)
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
            placeholder: Literals.placeholder,
            onSubmit: { isNicknameFocused = false },
            onClear: { store.send(.updateNickname("")) }
        )
        .disabled(store.state.nicknameValidationState == .checking)
    }
    
    var duplicateButton: some View {
        LivithConfirmButton(duplicateButtonText, variant: .dark) {
            isNicknameFocused = false
            store.send(.checkNicknameDuplicate)
        }
        .disabled(!isDuplicateButtonEnabled)
    }
    
    var nicknameStatus: some View {
        Text(statusMessage)
            .notosans(.caption1Regular)
            .foregroundColor(statusMessageColor)
    }
    
    var updateButton: some View {
        LivithButton(
            Literals.updateButtonText,
            variant: .primary,
            size: .large,
            isLoading: isUpdateLoading
        ) {
            store.send(.submitNickname)
        }
        .disabled(!isUpdateButtonEnabled || isUpdateLoading)
    }
}

// MARK: - Helpers

private extension NicknameUpdateView {
    var duplicateButtonText: String {
        store.state.nicknameValidationState == .available ? Literals.checkCompleted : Literals.checkDuplicate
    }
    
    var isDuplicateButtonEnabled: Bool {
        store.state.nicknameValidationState == .valid
    }
    
    var statusMessage: String {
        switch store.state.nicknameValidationState {
        case .idle:
            return Literals.statusIdle
        case .valid:
            return ""
        case .invalid:
            return Literals.statusInvalid
        case .checking:
            return ""
        case .available:
            return Literals.statusAvailable
        case .duplicate:
            return Literals.statusDuplicate
        }
    }
    
    var statusMessageColor: Color {
        switch store.state.nicknameValidationState {
        case .idle, .valid, .checking:
            return .livithColor(.black50)
        case .invalid, .duplicate:
            return .livithColor(.translation)
        case .available:
            return .livithColor(.yellow30)
        }
    }
    
    var isUpdateButtonEnabled: Bool {
        store.state.nicknameValidationState == .available
    }
    
    var isUpdateLoading: Bool {
        store.state.nicknameValidationState == .checking
    }
    
    var nicknameBinding: Binding<String> {
        Binding {
            store.state.nickname
        } set: { newValue in
            guard store.state.nicknameValidationState != .checking else { return }
            store.send(.updateNickname(newValue))
        }
    }
}

// MARK: - Literals

private extension NicknameUpdateView {
    enum Literals {
        static let navigationTitle = "닉네임 수정"
        static let title = "라이빗에서 사용할\n닉네임을 설정해 주세요"
        static let placeholder = "예시) 홍길동"
        static let checkDuplicate = "중복확인"
        static let checkCompleted = "확인완료"
        static let updateButtonText = "닉네임 변경"
        static let statusIdle = "10자리 이내, 문자/숫자로 입력 가능해요"
        static let statusInvalid = "닉네임 형식이 올바르지 않아요"
        static let statusAvailable = "사용할 수 있는 닉네임이에요!"
        static let statusDuplicate = "이미 존재하는 닉네임이에요"
        static let toastFailure = "닉네임 변경에 실패했어요"
    }
}
