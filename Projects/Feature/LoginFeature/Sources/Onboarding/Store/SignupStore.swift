//
//  SignupStore.swift
//  LoginFeature
//
//  Created by 김진웅 on 2/5/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

import DIContainer
import DisplaySupport
import Domain

enum SignupIntent {
    case submit([PreferredArtist])
    case _signupResult(Result<String, Error>)
}

struct SignupState: Equatable {
    enum Result: Equatable {
        case idle
        case success(nickname: String)
        case failure
    }
    
    var isSubmitting: Bool = false
    var result: Result = .idle
    var errorMessage: String = ""
}

final class SignupStore: ObservableObject {
    @Published private(set) var state = SignupState()
    
    @Injected private var authRepository: AuthRepository
    
    private let session: SignupSession
    
    init(session: SignupSession) {
        self.session = session
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
            case .success(let nickname):
                state.result = .success(nickname: nickname)
            case .failure(let error):
                state.errorMessage = DisplayErrorMessage.message(for: error)
                state.result = .failure
            }
        }
    }
}

// MARK: - Helpers

private extension SignupStore {
    func performSignup(preferredArtistList: [PreferredArtist]) {
        Task {
            do {
                let signup = try session.makeSignupInfo(preferredArtistList: preferredArtistList)
                
                let nickname = try await authRepository.signup(signup)
                
                await send(._signupResult(.success(nickname)))
            } catch {
                await send(._signupResult(.failure(error)))
            }
        }
    }
    
}
