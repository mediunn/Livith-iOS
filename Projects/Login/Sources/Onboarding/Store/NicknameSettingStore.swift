//
//  NicknameSettingStore.swift
//  LoginFeature
//
//  Created by 김진웅 on 11/8/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import Foundation

import DIContainer
import Domain

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

    @Injected private var authRepository: AuthRepository

    private let marketingConsent: Bool
    private let tempUser: TempUser

    init(marketingConsent: Bool, tempUser: TempUser) {
        self.marketingConsent = marketingConsent
        self.tempUser = tempUser
    }

    @MainActor
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
                let authError = error as? AuthError

                if authError == .duplicateNickname {
                    state.nicknameValidationStatus = .duplicate
                } else {
                    state.nicknameValidationStatus = .valid
                    state.errorMessage = getErrorMessage(from: error)
                }
            }

        case ._signupResult(let result):
            switch result {
            case .success:
                state.signupStatus = .success

            case .failure(let error):
                let authError = error as? AuthError
                let isRecoverableError = authError == .nicknameTooLong
                    || authError == .emptyNickname
                    || authError == .duplicateNickname

                if isRecoverableError {
                    state.errorMessage = getErrorMessage(from: error)
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

        let pattern = /^[a-zA-Z0-9가-힣]{1,10}$/
        if state.nickname.wholeMatch(of: pattern) != nil {
            state.nicknameValidationStatus = .valid
        } else {
            state.nicknameValidationStatus = .invalid
        }
    }

    func performDuplicateCheck() {
        Task {
            do {
                let isAvailable = try await authRepository.checkNicknameDuplicate(nickname: state.nickname)
                if isAvailable {
                    await send(._duplicateCheckResult(.success(())))
                } else {
                    await send(._duplicateCheckResult(.failure(AuthError.duplicateNickname)))
                }
            } catch {
                await send(._duplicateCheckResult(.failure(error)))
            }
        }
    }

    func performSignup() {
        Task {
            do {
                try await authRepository.signup(
                    tempUser: tempUser,
                    marketingConsent: marketingConsent,
                    nickname: state.nickname
                )
                await send(._signupResult(.success(())))
            } catch {
                await send(._signupResult(.failure(error)))
            }
        }
    }

    func getErrorMessage(from error: Error) -> String {
        let unknownMessage = AuthError.unknown.errorDescription ?? ""
        guard let authError = error as? AuthError else {
            return unknownMessage
        }
        return authError.errorDescription ?? unknownMessage
    }
}
