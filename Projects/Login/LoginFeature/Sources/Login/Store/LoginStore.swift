//
//  LoginStore.swift
//  LoginFeature
//
//  Created by 김진웅 on 12/8/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import Foundation

import DIContainer
import LoginDomain

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
    
    @Injected private var useCase: LoginUseCase
    
    init() {
        performFetchLastLoginPlatform()
    }

    @MainActor
    func send(_ intent: LoginIntent) {
        switch intent {
        case .kakaoLogin:
            state.status = nil
            state.errorMessage = ""
            performLogin(for: .kakao)
            
        case .appleLogin:
            state.status = nil
            state.errorMessage = ""
            performLogin(for: .apple)
            
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
    func performLogin(for socialProvider: SocialLoginProvider) {
        Task {
            do {
                let loginResult = try await useCase.execute(for: socialProvider)
                await send(._loginResult(.success(loginResult)))
            } catch {
                await send(._loginResult(.failure(error)))
            }
        }
    }

    func performFetchLastLoginPlatform() {
        Task {
            let platform = try? await useCase.lastLoginPlatform()
            await send(._setLastLoginPlatform(platform))
        }
    }
    
    func getErrorMessage(from error: Error) -> String {
        let unknownMessage = LoginError.unknown.errorDescription ?? ""
        guard let loginError = error as? LoginError else { return unknownMessage }

        switch loginError {
        case .canceled, .forbidden:
            return ""
        case .noConnection, .serverError, .notFound:
            return loginError.errorDescription ?? unknownMessage
        case .noData, .unknown:
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
