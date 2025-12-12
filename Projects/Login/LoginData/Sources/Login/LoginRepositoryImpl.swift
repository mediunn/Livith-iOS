//
//  LoginRepositoryImpl.swift
//  LoginData
//
//  Created by 김진웅 on 12/5/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import Foundation

import Auth
import LivithNetwork
import LoginDomain
import Persistence

final class LoginRepositoryImpl {
    private let appleLoginService: AppleLoginService
    private let kakaoLoginService: KakaoLoginService
    private let loginService: OnboardingService
    private let errorMapper: LoginErrorMapper
    private let localStorage: LocalKeyValueStorage
    
    init(
        appleLoginService: AppleLoginService = .init(),
        kakaoLoginService: KakaoLoginService = .init(),
        loginService: OnboardingService = .init(),
        errorMapper: LoginErrorMapper = .init(),
        localStorage: LocalKeyValueStorage = UserDefaultsStorage()
    ) {
        self.appleLoginService = appleLoginService
        self.kakaoLoginService = kakaoLoginService
        self.loginService = loginService
        self.errorMapper = errorMapper
        self.localStorage = localStorage
    }
}

extension LoginRepositoryImpl: LoginRepository {
    func login(for provider: SocialLoginProvider) async throws(LoginError) -> LoginStatus {
        do {
            let credential = try await getCredential(for: provider)
            return try await performBackendLogin(with: credential, for: provider)
        } catch {
            throw mapToDomainError(from: error)
        }
    }
    
    func lastLoginPlatform() async throws(LoginError) -> SocialLoginProvider {
        do {
            let value: String = try localStorage.fetch(for: LocalStorageKeys.lastLoginPlatform)
            switch value {
            case "apple":
                return .apple
            case "kakao":
                return .kakao
            default:
                throw LoginError.noData
            }
        } catch {
            throw LoginError.noData
        }
    }
}

// MARK: - Helpers

private extension LoginRepositoryImpl {
    func getCredential(for provider: SocialLoginProvider) async throws -> AuthCredential {
        switch provider {
        case .apple:
            return try await appleLoginService.login()
        case .kakao:
            return try await kakaoLoginService.login()
        }
    }
    
    func performBackendLogin(with credential: AuthCredential, for provider: SocialLoginProvider) async throws -> LoginStatus {
        switch provider {
        case .apple:
            let response: DTO.Response.AppleLogin = try await loginService.request(.appleLogin(identityToken: credential.token))
            
            if response.isNewUser {
                guard let tempUserData = response.tempUser else {
                    throw LoginError.noData
                }
                let tempUser = TempUser(
                    provider: .apple,
                    providerID: tempUserData.providerID,
                    email: tempUserData.email
                )
                return .newUser(tempUser: tempUser)
            } else {
                return .existingUser
            }
            
        case .kakao:
            let response: DTO.Response.KakaoLogin = try await loginService.request(.kakaoLogin(accessToken: credential.token))
            
            if response.isNewUser {
                guard let tempUserData = response.tempUser else {
                    throw LoginError.noData
                }
                let tempUser = TempUser(
                    provider: .kakao,
                    providerID: tempUserData.providerID,
                    email: nil
                )
                return .newUser(tempUser: tempUser)
            } else {
                return .existingUser
            }
        }
    }
    
    func mapToDomainError(from error: Error) -> LoginError {
        if let loginError = error as? LoginError {
            return loginError
        }
        if let authError = error as? AuthError {
            return errorMapper.mapToDomainError(authError)
        }
        if let networkError = error as? NetworkError {
            return errorMapper.mapToDomainError(networkError)
        }
        return .unknown
    }
}
