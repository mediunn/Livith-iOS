//
//  NicknameUpdateStore.swift
//  UserFeature
//
//  Created by Youjin Lee on 12/9/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import Foundation

import DIContainer
import Domain
import LivithFoundation

enum NicknameValidationState {
    case idle
    case valid
    case invalid
    case checking
    case available
    case duplicate
}

enum NicknameUpdateResult {
    case idle
    case success
    case failure
}

struct NicknameUpdateState {
    var nickname: String = ""
    var nicknameValidationState: NicknameValidationState = .idle
    var updateResult: NicknameUpdateResult = .idle
}

enum NicknameUpdateIntent {
    case updateNickname(String)
    case checkNicknameDuplicate
    case submitNickname
    case _setNicknameValidationState(NicknameValidationState)
    case _setUpdateResult(NicknameUpdateResult)
}

final class NicknameUpdateStore: ObservableObject {
    @Published private(set) var state = NicknameUpdateState()
    @Injected private var authRepository: AuthRepository
    @Injected private var userRepository: UserRepository
    
    func send(_ intent: NicknameUpdateIntent) {
        switch intent {
        case .updateNickname(let nickname):
            state.nickname = nickname
            validateNicknameFormat()

        case .checkNicknameDuplicate:
            state.nicknameValidationState = .checking
            checkNicknameDuplicate()

        case .submitNickname:
            state.updateResult = .idle
            submitNickname()

        case ._setNicknameValidationState(let validationState):
            state.nicknameValidationState = validationState

        case ._setUpdateResult(let result):
            state.updateResult = result
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

        let pattern = /^[a-zA-Z0-9가-힣]{1,10}$/
        guard state.nickname.wholeMatch(of: pattern) != nil else {
            send(._setNicknameValidationState(.invalid))
            return
        }

        send(._setNicknameValidationState(.valid))
    }
    
    func checkNicknameDuplicate() {
        Task {
            do {
                let isAvailable = try await authRepository.checkNicknameDuplicate(nickname: state.nickname)
                await MainActor.run {
                    send(._setNicknameValidationState(isAvailable ? .available : .duplicate))
                }
            } catch {
                await MainActor.run { send(._setNicknameValidationState(.duplicate)) }
            }
        }
    }

    func submitNickname() {
        Task {
            do {
                try await userRepository.updateNickname(state.nickname)
                await MainActor.run { send(._setUpdateResult(.success)) }
            } catch {
                await MainActor.run { send(._setUpdateResult(.failure)) }
            }
        }
    }
}
