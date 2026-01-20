//
//  AuthRepository.swift
//  Domain
//
//  Created by 김진웅 on 1/21/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

public protocol AuthRepository {
    // Login
    func login(for provider: SocialLoginProvider) async throws(AuthError) -> LoginStatus
    func fetchLastLoginPlatform() async throws(AuthError) -> SocialLoginProvider
    
    // User
    func checkNicknameDuplicate(nickname: String) async throws(AuthError) -> Bool
    func updateUserNickname(nickname: String) async throws(AuthError) -> String
    func deleteUser(reason: String) async throws(AuthError) -> Void
    func logoutSession() async throws(AuthError) -> Void
}
