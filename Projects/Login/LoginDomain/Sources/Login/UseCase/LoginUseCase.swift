//
//  LoginUseCase.swift
//  LoginDomain
//
//  Created by 김진웅 on 12/5/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import Foundation

public protocol LoginUseCase {
    func execute(for provider: SocialLoginProvider) async throws(LoginError) -> LoginResult
}

public final class LoginUseCaseImpl: LoginUseCase {
    private let repository: LoginRepository
    
    public init(repository: LoginRepository) {
        self.repository = repository
    }
    
    public func execute(for provider: SocialLoginProvider) async throws(LoginError) -> LoginResult {
        return try await repository.login(for: provider)
    }
}
