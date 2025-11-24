//
//  NicknameSettingStore.swift
//  OnboardingFeature
//
//  Created by 김진웅 on 11/8/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import Foundation

import DIContainer
import OnboardingDomain

struct NicknameSettingState {
    var nickname: String = ""
    var nicknameValidationState: NicknameValidationState = .idle
    var signupState: SignupState = .idle
}

enum NicknameSettingIntent {
    case updateNickname(String)
    case checkNicknameDuplicate
    case signup
    case _setNicknameValidationState(NicknameValidationState)
    case _signupResult(Result<Void, OnboardingError>)
}

@MainActor
final class NicknameSettingStore: ObservableObject {
    @Published private(set) var state = NicknameSettingState()
    
    @Injected(container: OnboardingPreviewDIContainer.shared) private var onboardingUseCase: OnboardingUseCase
    
    init() {}
    
    func send(_ intent: NicknameSettingIntent) {
        switch intent {
        case .updateNickname(let nickname):
            state.nickname = nickname
            validateNicknameFormat()

        case .checkNicknameDuplicate:
            state.nicknameValidationState = .checking
            checkNicknameDuplicate()

        case .signup:
            state.signupState = .loading
            signup()

        case ._setNicknameValidationState(let validationState):
            state.nicknameValidationState = validationState

        case ._signupResult(let result):
            switch result {
            case .success:
                state.signupState = .success

            case .failure(let error):
                state.signupState = .failure(error.localizedDescription)
            }
        }
    }
}

// MARK: - Helper

private extension NicknameSettingStore {
    func validateNicknameFormat() {
        guard !state.nickname.isEmpty else {
            send(._setNicknameValidationState(.idle))
            return
        }
        
        do {
            try onboardingUseCase.validateNicknameFormat(state.nickname)
            send(._setNicknameValidationState(.valid))
        } catch {
            send(._setNicknameValidationState(.invalid))
        }
    }
    
    func checkNicknameDuplicate() {
        Task {
            do {
                try await onboardingUseCase.checkNicknameDuplicate(state.nickname)
                send(._setNicknameValidationState(.available))
            } catch {
                send(._setNicknameValidationState(.duplicate))
            }
        }
    }
    
    func signup() {
        Task {
            do {
                try await onboardingUseCase.signup(nickname: state.nickname)
                send(._signupResult(.success(())))
            } catch let error as OnboardingError {
                send(._signupResult(.failure(error)))
            }
        }
    }
}
