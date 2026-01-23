//
//  LoginStore.swift
//  LoginFeature
//
//  Created by 김진웅 on 12/8/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import Foundation

import DIContainer
import Domain

enum LoginIntent {
    case kakaoLogin
    case appleLogin
    case setErrorMessage(String)
    case _loginResult(Result<LoginStatus, Error>)
    case _setLastLoginPlatform(SocialLoginProvider?)
}

struct LoginState {
    var status: LoginStatus?
    var lastLoginPlatform: SocialLoginProvider?
    var errorMessage: String = ""
}

final class LoginStore: ObservableObject {
    @Published private(set) var state: LoginState = .init()

    @Injected private var authRepository: AuthRepository

    init() {
        performFetchLastLoginPlatform()
    }

    @MainActor
    func send(_ intent: LoginIntent) {
        switch intent {
        case .kakaoLogin:
            state.status = nil
            state.errorMessage = ""
            performKakaoLogin()

        case .appleLogin:
            state.status = nil
            state.errorMessage = ""
            performAppleLogin()

        case .setErrorMessage(let message):
            state.errorMessage = message

        case ._loginResult(let result):
            switch result {
            case .success(let loginResult):
                state.status = loginResult
            case .failure(let error):
                state.errorMessage = getErrorMessage(from: error)
            }

        case ._setLastLoginPlatform(let value):
            state.lastLoginPlatform = value
        }
    }
}

// MARK: - Helpers

private extension LoginStore {
    func performKakaoLogin() {
        Task {
            do {
                let loginResult = try await authRepository.kakaoLogin()
                await send(._loginResult(.success(loginResult)))
            } catch AuthError.recentWithdrawal {
                await send(._loginResult(.success(.forbidden)))
            } catch {
                await send(._loginResult(.failure(error)))
            }
        }
    }

    func performAppleLogin() {
        Task {
            do {
                let loginResult = try await authRepository.appleLogin()
                await send(._loginResult(.success(loginResult)))
            } catch AuthError.recentWithdrawal {
                await send(._loginResult(.success(.forbidden)))
            } catch {
                await send(._loginResult(.failure(error)))
            }
        }
    }

    func performFetchLastLoginPlatform() {
        Task {
            let platform = try? await authRepository.fetchLastLoginPlatform()
            await send(._setLastLoginPlatform(platform))
        }
    }

    func getErrorMessage(from error: Error) -> String {
        let unknownMessage = AuthError.unknown.errorDescription ?? ""
        guard let authError = error as? AuthError else { return unknownMessage }

        switch authError {
        case .cancelled, .recentWithdrawal:
            return ""
        case .noConnection, .serverError, .userNotFound:
            return authError.errorDescription ?? unknownMessage
        default:
            return unknownMessage
        }
    }
}

// MARK: - LoginState Extension

extension LoginState {
    typealias CalloutMessage = (text: String, targetText: String)
    
    var calloutMessage: CalloutMessage {
        switch lastLoginPlatform {
        case .apple:
            return ("Apple로 최근에 로그인 했어요", "Apple")
        case .kakao:
            return ("카카오로 최근에 로그인 했어요", "카카오")
        case .none:
            return ("회원가입하고 모든 서비스 이용해보세요!", "모든 서비스 이용")
        }
    }
}
