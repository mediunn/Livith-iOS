//
//  SignupStore.swift
//  LoginFeature
//
//  Created by 김진웅 on 2/5/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

import DIContainer
import Domain

enum SignupIntent {
    case submit([PreferredArtist])
    case _signupResult(Result<Void, Error>)
}

struct SignupState: Equatable {
    enum Result: Equatable {
        case idle
        case success
        case failure(String)
    }
    
    var isSubmitting: Bool = false
    var result: Result = .idle
}

final class SignupStore: ObservableObject {
    @Published private(set) var state = SignupState()
    
    @Injected private var authRepository: AuthRepository
    
    private let builder: SignupBuilder
    
    init(builder: SignupBuilder) {
        self.builder = builder
    }
    
    @MainActor
    func send(_ intent: SignupIntent) {
        switch intent {
        case .submit(let preferredArtistList):
            state.isSubmitting = true
            state.result = .idle
            performSignup(preferredArtistList: preferredArtistList)
            
        case ._signupResult(let result):
            state.isSubmitting = false
            switch result {
            case .success:
                state.result = .success
            case .failure(let error):
                state.result = .failure(getErrorMessage(from: error))
            }
        }
    }
}

// MARK: - Helpers

private extension SignupStore {
    func performSignup(preferredArtistList: [PreferredArtist]) {
        Task {
            do {
                let signup = try builder.build(preferredArtistList: preferredArtistList)
                
                try await authRepository.signup(signup)
                
                await send(._signupResult(.success(())))
            } catch {
                await send(._signupResult(.failure(error)))
            }
        }
    }
    
    func getErrorMessage(from error: Error) -> String {
        let unknownMessage = AuthError.unknown.errorDescription ?? "로그인에서 다시 시도 주세요"
        guard let authError = error as? AuthError else { return error.localizedDescription }
        return authError.errorDescription ?? unknownMessage
    }
}
