//
//  AuthRepository.swift
//  Domain
//
//  Created by 김진웅 on 1/21/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

public protocol AuthRepository {
    func withdraw(reason: String) async throws(AuthError)
    func logout() async throws(AuthError)
    func checkNicknameDuplicate(nickname: String) async throws(AuthError) -> Bool
    func signup(tempUser: TempUser, marketingConsent: Bool, nickname: String) async throws(AuthError)
    func kakaoLogin() async throws(AuthError) -> LoginStatus
    func appleLogin() async throws(AuthError) -> LoginStatus
    func fetchLastLoginPlatform() async throws(AuthError) -> SocialLoginProvider
}
