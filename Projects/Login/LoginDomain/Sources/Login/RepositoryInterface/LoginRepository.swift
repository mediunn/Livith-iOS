//
//  LoginRepository.swift
//  LoginDomain
//
//  Created by 김진웅 on 12/5/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import Foundation

public protocol LoginRepository {
    func login(for provider: SocialLoginProvider) async throws(LoginError) -> LoginResult
}
