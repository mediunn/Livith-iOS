//
//  NicknameSettingView.swift
//  LoginFeature
//
//  Created by 김진웅 on 11/5/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import SwiftUI

import DSKit
import LoginDomain

struct NicknameSettingView: View {
    @ObservedObject var store: NicknameSettingStore
    @Environment(\.loginCoordinator) private var coordinator
    @FocusState private var isNicknameFocused: Bool
    private let maxNicknameLength = 10
    
    init(store: NicknameSettingStore) {
        self.store = store
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
                
                stepIndicator
                    .padding(.top, 20)
                
                title
                    .padding(.top, 32)
                
                nicknameInputSection
                    .padding(.top, 20)
                
                nicknameStatus
                    .padding(.top, 8)
                
                Spacer()
                
                signupButton
                    .padding(.bottom, 50)
            }
            .padding(.horizontal, 16)
        }
        .livithToast(
            isPresented: Binding(
                get: { !store.state.errorMessage.isEmpty },
                set: { _ in store.send(.setErrorMessage("")) }
            ),
            type: .failure,
            message: store.state.errorMessage,
            duration: 2,
            position: .safeAreaTop
        )
        .ignoresSafeArea(.all, edges: .bottom)
        .onChange(of: store.state.signupStatus) {
            oldValue,
            newValue in
            switch newValue {
            case .success:
                coordinator?.completeSignup(with: store.state.nickname)
                
            case .failure:
                coordinator?.present(
                    to: .signupFailed,
                    presentationStyle: .overFullScreen,
                    transitionStyle: .crossDissolve
                )
                
            default:
                break
            }
        }
    }
}

// MARK: - UIComponents

private extension NicknameSettingView {
    var navigationBar: some View {
        HStack {
            Button(action: {
                coordinator?.pop()
            }) {
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
                    .disabled(store.state.nicknameValidationStatus == .checking)
                
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
        .cornerRadius(12)
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
                .cornerRadius(12)
        }
        .disabled(!isDuplicateButtonEnabled)
    }
    
    var nicknameStatus: some View {
        Text(statusMessage)
            .notosans(.caption1Regular)
            .foregroundColor(statusMessageColor)
    }
    
    var signupButton: some View {
        LivithButton(
            Literals.signupButtonText,
            variant: .primary,
            size: .large,
            isLoading: isSignupLoading
        ) {
            store.send(.signup)
        }
        .disabled(!isSignupButtonEnabled || isSignupLoading)
    }
}

// MARK: - Helpers

private extension NicknameSettingView {
    var duplicateButtonText: String {
        store.state.nicknameValidationStatus == .available ? Literals.checkCompleted : Literals.checkDuplicate
    }
    
    var isDuplicateButtonEnabled: Bool {
        store.state.nicknameValidationStatus == .valid
    }
    
    var statusMessage: String {
        switch store.state.nicknameValidationStatus {
        case .idle:
            return "10자리 이내 문자/숫자로 입력 가능해요"
        case .valid:
            return ""
        case .invalid:
            return "닉네임 형식이 올바르지 않아요"
        case .checking:
            return ""
        case .available:
            return "사용할 수 있는 닉네임이에요!"
        case .duplicate:
            return "이미 존재하는 닉네임이에요"
        }
    }
    
    var statusMessageColor: Color {
        switch store.state.nicknameValidationStatus {
        case .idle, .valid, .checking:
            return .livithColor(.black50)
        case .invalid, .duplicate:
            return .livithColor(.translation)
        case .available:
            return .livithColor(.yellow30)
        }
    }
    
    var isSignupButtonEnabled: Bool {
        store.state.nicknameValidationStatus == .available
    }
    
    var isSignupLoading: Bool {
        store.state.signupStatus == .loading
    }
    
    var nicknameBinding: Binding<String> {
        Binding {
            store.state.nickname
        } set: { newValue in
            guard store.state.nicknameValidationStatus != .checking else { return }
            store.send(.updateNickname(newValue))
        }
    }
}

// MARK: - Literals

private extension NicknameSettingView {
    enum Literals {
        static let navigationTitle = "회원가입"
        static let title = "리이빗에서 사용할\n닉네임을 설정해 주세요"
        static let placeholder = "예시) 홍길동"
        static let checkDuplicate = "중복확인"
        static let checkCompleted = "확인완료"
        static let signupButtonText = "가입 완료"
        static let errorAlertTitle = "알림"
        static let confirmButtonTitle = "확인"
    }
}
