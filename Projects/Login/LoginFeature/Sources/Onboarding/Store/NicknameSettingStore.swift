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
    var errorMessage: String?
}

enum NicknameSettingIntent {
    case updateNickname(String)
    case checkNicknameDuplicate
    case signup
    case confirmAlert
    case _setNicknameValidationState(NicknameValidationStatus)
    case _validateResult(Result<Void, Error>)
    case _duplicateResult(Result<Void, Error>)
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
            validateNicknameFormat()
            
        case .checkNicknameDuplicate:
            state.nicknameValidationStatus = .checking
            checkNicknameDuplicate()
            
        case .signup:
            state.signupStatus = .loading
            signup()
            
        case .confirmAlert:
            state.errorMessage = nil
            state.signupStatus = .idle
            
        case ._setNicknameValidationState(let validationState):
            state.nicknameValidationStatus = validationState
        
        case ._validateResult(let result):
            switch result {
            case .success:
                state.nicknameValidationStatus = .valid
            case .failure:
                state.nicknameValidationStatus = .invalid
            }
            
        case ._duplicateResult(let result):
            switch result {
            case .success:
                state.nicknameValidationStatus = .available
                
            case .failure(let error):
                guard let onboardingError = error as? OnboardingError,
                      onboardingError == .nicknameDuplicated
                else {
                    state.nicknameValidationStatus = .valid
                    state.errorMessage = errorMessage(error)
                    return
                }
                state.nicknameValidationStatus = .duplicate
            }
            
        case ._signupResult(let result):
            switch result {
            case .success:
                state.signupStatus = .success
                
            case .failure(let error):
                guard let onboardingError = error as? OnboardingError,
                      onboardingError == .unknown || onboardingError == .serverError
                else {
                    state.errorMessage = errorMessage(error)
                    return
                }

                state.signupStatus = .failure
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
        
        Task {
            do {
                try onboardingUseCase.validateNicknameFormat(state.nickname)
                await MainActor.run { send(._validateResult(.success(()))) }
            } catch {
                await MainActor.run { send(._validateResult(.failure(error))) }
            }
        }
    }
    
    func checkNicknameDuplicate() {
        Task {
            do {
                try await onboardingUseCase.checkNicknameDuplicate(state.nickname)
                await MainActor.run { send(._duplicateResult(.success(()))) }
            } catch {
                await MainActor.run { send(._duplicateResult(.failure(error))) }
            }
        }
    }
    
    func signup() {
        Task {
            do {
                try await onboardingUseCase.signup(nickname: state.nickname)
                await MainActor.run { send(._signupResult(.success(()))) }
            } catch {
                await MainActor.run { send(._signupResult(.failure(error))) }
            }
        }
    }
    
    func errorMessage(_ error: Error) -> String? {
        guard let onboardingError = error as? OnboardingError else {
            return OnboardingError.unknown.errorDescription
        }
        
        return onboardingError.errorDescription
    }
}
