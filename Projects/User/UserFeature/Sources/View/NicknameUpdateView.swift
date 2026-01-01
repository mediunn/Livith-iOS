//
//  NicknameUpdateView.swift
//  LoginFeature
//
//  Created by Youjin Lee on 12/9/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import SwiftUI

import DSKit

struct NicknameUpdateView: View {
    
    // MARK: - Property

    private let maxNicknameLength = 10

    @FocusState private var isNicknameFocused: Bool
    @State private var showFailureToast: Bool = false
    @ObservedObject private var store: NicknameUpdateStore

    var onDismiss: (() -> Void)?
    var onSuccess: (() -> Void)?

    // MARK: - LifeCycle

    init(
        store: NicknameUpdateStore,
        onDismiss: (() -> Void)? = nil,
        onSuccess: (() -> Void)? = nil
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
                    .padding(.top, 20)
                
                title
                    .padding(.top, 32)
                
                nicknameInputSection
                    .padding(.top, 20)
                
                nicknameStatus
                    .padding(.top, 8)
                
                Spacer()
                
                updateButton
                    .padding(.bottom, 50)
            }
            .padding(.horizontal, 16)
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
                onSuccess?()
            case .failure:
                withAnimation { showFailureToast = true }
            }
        }
    }
}

// MARK: - UIComponents

private extension NicknameUpdateView {
    var navigationBar: some View {
        HStack {
            Button {
                onDismiss?()
            } label: {
                Image.livithIcon(.backLineDefault)
                    .foregroundColor(.livithColor(.white100))
            }

            Text(Literals.navigationTitle)
                .notosans(.body1Semibold)
                .foregroundColor(.livithColor(.white100))

            Spacer()
        }
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
        ZStack(alignment: .leading) {
            if store.state.nickname.isEmpty, !isNicknameFocused {
                Text(Literals.placeholder)
                    .notosans(.body3Medium)
                    .foregroundColor(Color.livithColor(.black50))
            }
            
            HStack {
                TextField("", text: nicknameBinding)
                    .foregroundColor(.livithColor(.white100))
                    .notosans(.body3Medium)
                    .autocorrectionDisabled()
                    .onChange(of: store.state.nickname) { oldValue, newValue in
                        if newValue.count > maxNicknameLength {
                            store.send(.updateNickname(oldValue))
                        }
                    }
                    .focused($isNicknameFocused)
                    .onSubmit {
                        isNicknameFocused = false
                    }
                    .disabled(store.state.nicknameValidationState == .checking)
                
                if !store.state.nickname.isEmpty {
                    Spacer()
                    Text("\(store.state.nickname.count)/\(maxNicknameLength)")
                        .notosans(.caption1Regular)
                        .foregroundColor(.livithColor(.black50))
                    if isNicknameFocused {
                        Button {
                            store.send(.updateNickname(""))
                        } label: {
                            Image.livithIcon(.deleteFillDefault)
                                .frame(width: 24, height: 24)
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color.livithColor(.black90))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.livithColor(.black50), lineWidth: isNicknameFocused ? 1 : 0)
        )
    }
    
    var duplicateButton: some View {
        Button {
            isNicknameFocused = false
            store.send(.checkNicknameDuplicate)
        } label: {
            Text(duplicateButtonText)
                .notosans(.body3Medium)
                .foregroundColor(isDuplicateButtonEnabled ? .livithColor(.black5) : .livithColor(.black50))
                .padding()
                .frame(minWidth: 80)
                .background(Color.livithColor(.black80))
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .disabled(!isDuplicateButtonEnabled)
    }
    
    var nicknameStatus: some View {
        Text(statusMessage)
            .notosans(.caption1Regular)
            .foregroundColor(statusMessageColor)
    }
    
    var updateButton: some View {
        Button {
            store.send(.submitNickname)
        } label: {
            HStack(spacing: 8) {
                Text(Literals.updateButtonText)
                    .notosans(.body2Medium)
                    .foregroundColor(isUpdateButtonEnabled ? .livithColor(.black100) : .livithColor(.black30))
                if case .checking = store.state.nicknameValidationState {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .livithColor(.black100)))
                }
            }
            .padding()
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(isUpdateButtonEnabled ? Color.livithColor(.yellow30) : Color.livithColor(.black50))
            .clipShape(RoundedRectangle(cornerRadius: 8))
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
            return .livithColor(.transition)
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
        static let statusIdle = "10자리 이내 문자/숫자로 입력 가능해요"
        static let statusInvalid = "닉네임 형식이 올바르지 않아요"
        static let statusAvailable = "사용할 수 있는 닉네임이에요!"
        static let statusDuplicate = "이미 존재하는 닉네임이에요"
        static let toastFailure = "닉네임 변경에 실패했어요"
    }
}
