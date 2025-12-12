//
//  NicknameUpdateStore.swift
//  UserFeature
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
    case submitNickname
    case _setNicknameValidationState(NicknameValidationState)
    case _setUpdateResult(Result<Void, UserError>)
}

final class NicknameUpdateStore: ObservableObject {
    @Published private(set) var state = NicknameUpdateState()
    @Injected private var repository: UserRepository
    
    func send(_ intent: NicknameUpdateIntent) {
        switch intent {
        case .updateNickname(let nickname):
            state.nickname = nickname
            validateNicknameFormat()

        case .checkNicknameDuplicate:
            state.nicknameValidationState = .checking
            checkNicknameDuplicate()

        case .submitNickname:
            submitNickname()

        case ._setNicknameValidationState(let validationState):
            state.nicknameValidationState = validationState

        case ._setUpdateResult(let result):
            switch result {
            case .success:
                state.isSucceed = true
            case .failure:
                state.isSucceed = false
            }
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
                _ = try await repository.checkNicknameDuplicate(nickname: state.nickname)
                await MainActor.run { send(._setNicknameValidationState(.available)) }
            } catch {
                await MainActor.run { send(._setNicknameValidationState(.duplicate)) }
            }
        }
    }

    func submitNickname() {
        Task {
            do {
                _ = try await repository.updateUserNickname(nickname: state.nickname)
                await MainActor.run { send(._setUpdateResult(.success(()))) }
            } catch let error as UserError {
                await MainActor.run { send(._setUpdateResult(.failure(error))) }
            }
        }
    }
}
