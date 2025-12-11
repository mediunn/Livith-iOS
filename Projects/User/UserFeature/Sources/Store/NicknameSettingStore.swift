//
//  NicknameUpdateStore.swift
//  LoginFeature
//
//  Created by Youjin Lee on 12/9/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import Foundation

import DIContainer
import LivithConcurrency
import UserDomain

enum NicknameValidationState {
    case idle
    case valid
    case invalid
    case checking
    case available
    case duplicate
}

struct NicknameUpdateState {
    var nickname: String = ""
    var nicknameValidationState: NicknameValidationState = .idle
    var isSucceed: Bool = false
}

enum NicknameUpdateIntent {
    case updateNickname(String)
    case checkNicknameDuplicate
    case _setNicknameValidationState(NicknameValidationState)
}

final class NicknameUpdateStore: ObservableObject {
    @Published private(set) var state = NicknameUpdateState()
    @Injected private var repository: SearchRepository
    
    func send(_ intent: NicknameUpdateIntent) {
        switch intent {
        case .updateNickname(let nickname):
            state.nickname = nickname
            validateNicknameFormat()
            
        case .checkNicknameDuplicate:
            state.nicknameValidationState = .checking
            checkNicknameDuplicate()
            
        case ._setNicknameValidationState(let validationState):
            state.nicknameValidationState = validationState
        }
    }
}

// MARK: - Helper

private extension NicknameUpdateStore {
    func validateNicknameFormat() {
        guard !state.nickname.isEmpty else {
            send(._setNicknameValidationState(.idle))
            return
        }
        
        Task {
            do {
                try onboardingUseCase.validateNicknameFormat(state.nickname)
                await MainActor.run { send(._setNicknameValidationState(.valid)) }
            } catch {
                await MainActor.run { send(._setNicknameValidationState(.invalid)) }
            }
        }
    }
    
    func checkNicknameDuplicate() {
        Task {
            do {
                try await onboardingUseCase.checkNicknameDuplicate(state.nickname)
                await MainActor.run { send(._setNicknameValidationState(.available)) }
            } catch {
                await MainActor.run { send(._setNicknameValidationState(.duplicate)) }
            }
        }
    }
    
    func signup() {
        Task {
            do {
                try await onboardingUseCase.signup(nickname: state.nickname)
                await MainActor.run { send(._signupResult(.success(()))) }
            } catch let error as UserError {
                await MainActor.run { send(._signupResult(.failure(error))) }
            }
        }
    }
}
