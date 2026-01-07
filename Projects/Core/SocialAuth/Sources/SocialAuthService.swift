//
//  SocialAuthService.swift
//  SocialAuth
//
//  Created by 김진웅 on 1/7/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

public struct SocialAuthService {
    private let appleAuthenticator: SocialAuthenticator = AppleAuthenticator()
    private let kakaoAuthenticator: SocialAuthenticator = KakaoAuthenticator()

    public init() {}

    public func signIn(with vendor: SocialAuthVendor) async throws(SocialAuthError) -> SocialAuthCredential {
        switch vendor {
        case .apple:
            return try await appleAuthenticator.signIn()
        case .kakao:
            return try await kakaoAuthenticator.signIn()
        }
    }
}
