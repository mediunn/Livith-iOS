//
//  KakaoAuthenticator.swift
//  SocialAuth
//
//  Created by 김진웅 on 12/4/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import Foundation

import KakaoSDKAuth
import KakaoSDKUser
import KakaoSDKCommon

struct KakaoAuthenticator: SocialAuthenticator, Sendable {
    typealias KakaoUserAPI = UserApi
    typealias KakaoLoginCompletion = (OAuthToken?, Error?) -> Void
    
    @MainActor
    func signIn() async throws(SocialAuthError) -> SocialAuthCredential {
        do {
            return try await withCheckedThrowingContinuation { continuation in
                self.performKakaoLogin(continuation: continuation)
            }
        } catch let authError as SocialAuthError {
            throw authError
        } catch {
            throw .unknown
        }
    }
}

// MARK: - Helpers

private extension KakaoAuthenticator {
    @MainActor
    func performKakaoLogin(continuation: CheckedContinuation<SocialAuthCredential, Error>) {
        let completion = self.handleLoginResult(continuation: continuation)
        
        if KakaoUserAPI.isKakaoTalkLoginAvailable() {
            KakaoUserAPI.shared.loginWithKakaoTalk(completion: completion)
        } else {
            KakaoUserAPI.shared.loginWithKakaoAccount(completion: completion)
        }
    }
    
    func handleLoginResult(continuation: CheckedContinuation<SocialAuthCredential, Error>) -> KakaoLoginCompletion {
        return { token, error in
            if let error = error {
                let authError = self.convertToAuthError(from: error)
                continuation.resume(throwing: authError)
                return
            }
            
            guard let oauthToken = token else {
                continuation.resume(throwing: SocialAuthError.missingToken)
                return
            }
            
            let credential = self.createCredential(from: oauthToken)
            continuation.resume(returning: credential)
        }
    }
    
    func createCredential(from token: OAuthToken) -> SocialAuthCredential {
        return SocialAuthCredential(
            provider: .kakao,
            token: token.accessToken,
            userID: nil
        )
    }
    
    func convertToAuthError(from error: Error) -> SocialAuthError {
        guard let sdkError = error as? SdkError else {
            return .unknown
        }
        
        if case .ClientFailed(let reason, _) = sdkError, reason == .Cancelled {
            return .canceled
        }
        
        return .unknown
    }
}
