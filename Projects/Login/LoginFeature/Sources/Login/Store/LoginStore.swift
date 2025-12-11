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
    case onAppear
    case kakaoLogin
    case appleLogin
    case _loginResult(Result<LoginStatus, Error>)
}

struct LoginState {
    var status: LoginStatus?
    var errorMessage: String?
}

final class LoginStore: ObservableObject {
    @Published private(set) var state: LoginState = .init()
    
    @Injected private var useCase: LoginUseCase
    
    func send(_ intent: LoginIntent) {
        switch intent {
        case .onAppear:
            state.status = nil
            state.errorMessage = nil
            
        case .kakaoLogin:
            performLogin(for: .kakao)
            
        case .appleLogin:
            performLogin(for: .apple)
            
        case ._loginResult(let result):
            switch result {
            case .success(let loginResult):
                state.status = loginResult
            case .failure(let error):
                // TODO: LoginError 중 forbidden 처리 -> 탈퇴 후 7일 이내 로그인 불가 알림
                state.errorMessage = formatErrorMessage(from: error)
            }
        }
    }
}

// MARK: - Helpers

private extension LoginStore {
    func performLogin(for socialProvider: SocialLoginProvider) {
        Task {
            do {
                let loginResult = try await useCase.execute(for: socialProvider)
                await MainActor.run { send(._loginResult(.success(loginResult))) }
            } catch {
                await MainActor.run { send(._loginResult(.failure(error))) }
            }
        }
    }
    
    func formatErrorMessage(from error: Error) -> String? {
        guard let loginError = error as? LoginError else { return LoginError.unknown.errorDescription }
        
        switch loginError {
        case .canceled, .forbidden:
            return nil
        case .noConnection, .serverError, .notFound:
            return loginError.errorDescription
        case .noData, .unknown:
            return LoginError.unknown.errorDescription
        }
    }
}
