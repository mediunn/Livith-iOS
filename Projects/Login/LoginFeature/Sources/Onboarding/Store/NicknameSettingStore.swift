//
//  NicknameSettingStore.swift
//  LoginFeature
//
//  Created by 김진웅 on 11/8/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import Foundation

import DIContainer
import LoginDomain

struct NicknameSettingState {
    var nickname: String = ""
    var nicknameValidationStatus: NicknameValidationStatus = .idle
    var signupStatus: SignupStatus = .idle
    var errorMessage: String = ""
}

enum NicknameSettingIntent {
    case updateNickname(String)
    case checkNicknameDuplicate
    case signup
    case setErrorMessage(String)
    case _validationResult(Result<Void, Error>)
    case _duplicateCheckResult(Result<Void, Error>)
    case _signupResult(Result<Void, Error>)
}

final class NicknameSettingStore: ObservableObject {
    @Published private(set) var state = NicknameSettingState()
    
    @Injected private var onboardingUseCase: OnboardingUseCase
    
    private let marketingConsent: Bool
    private let tempUser: TempUser
    
    init(marketingConsent: Bool, tempUser: TempUser) {
        self.marketingConsent = marketingConsent
        self.tempUser = tempUser
    }
    
    func send(_ intent: NicknameSettingIntent) {
        switch intent {
        case .updateNickname(let nickname):
            state.nickname = nickname
            performNicknameValidation()
            
        case .checkNicknameDuplicate:
            state.nicknameValidationStatus = .checking
            performDuplicateCheck()
            
        case .signup:
            state.signupStatus = .loading
            performSignup()
            
        case .setErrorMessage(let message):
            state.errorMessage = message
            
        case ._validationResult(let result):
            switch result {
            case .success:
                state.nicknameValidationStatus = .valid
            case .failure:
                state.nicknameValidationStatus = .invalid
            }
            
        case ._duplicateCheckResult(let result):
            switch result {
            case .success:
                state.nicknameValidationStatus = .available
                
            case .failure(let error):
                let onboardingError = error as? OnboardingError
                
                if onboardingError == .nicknameDuplicated {
                    state.nicknameValidationStatus = .duplicate
                } else {
                    state.nicknameValidationStatus = .valid
                    state.errorMessage = formatErrorMessage(error)
                }
            }
            
        case ._signupResult(let result):
            switch result {
            case .success:
                state.signupStatus = .success
                
            case .failure(let error):
                let onboardingError = error as? OnboardingError
                let isRecoverableError = onboardingError == .invalidNicknameFormat || onboardingError == .nicknameDuplicated
                
                if isRecoverableError {
                    state.errorMessage = formatErrorMessage(error)
                } else {
                    state.signupStatus = .failure
                }
            }
        }
    }
}

// MARK: - Helper

private extension NicknameSettingStore {
    func performNicknameValidation() {
        guard !state.nickname.isEmpty else {
            state.nicknameValidationStatus = .idle
            return
        }
        
        Task {
            do {
                try onboardingUseCase.validateNicknameFormat(state.nickname)
                await MainActor.run { send(._validationResult(.success(()))) }
            } catch {
                await MainActor.run { send(._validationResult(.failure(error))) }
            }
        }
    }
    
    func performDuplicateCheck() {
        Task {
            do {
                try await onboardingUseCase.checkNicknameDuplicate(state.nickname)
                await MainActor.run { send(._duplicateCheckResult(.success(()))) }
            } catch {
                await MainActor.run { send(._duplicateCheckResult(.failure(error))) }
            }
        }
    }
    
    func performSignup() {
        Task {
            do {
                try await onboardingUseCase.signup(
                    marketingConsent: marketingConsent,
                    nickname: state.nickname,
                    tempUser: tempUser
                )
                await MainActor.run { send(._signupResult(.success(()))) }
            } catch {
                await MainActor.run { send(._signupResult(.failure(error))) }
            }
        }
    }
    
    func formatErrorMessage(_ error: Error) -> String {
        guard let onboardingError = error as? OnboardingError else {
            return OnboardingError.unknown.errorDescription
        }
        return onboardingError.errorDescription
    }
}
