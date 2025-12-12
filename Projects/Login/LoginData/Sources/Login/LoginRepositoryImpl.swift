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
    private let tokenService: TokenService
    
    init(
        appleLoginService: AppleLoginService = .init(),
        kakaoLoginService: KakaoLoginService = .init(),
        loginService: OnboardingService = .init(),
        errorMapper: LoginErrorMapper = .init(),
        localStorage: LocalKeyValueStorage = UserDefaultsStorage(),
        tokenService: TokenService = TokenServiceImpl()
    ) {
        self.appleLoginService = appleLoginService
        self.kakaoLoginService = kakaoLoginService
        self.loginService = loginService
        self.errorMapper = errorMapper
        self.localStorage = localStorage
        self.tokenService = tokenService
    }
}

extension LoginRepositoryImpl: LoginRepository {
    func login(for provider: SocialLoginProvider) async throws(LoginError) -> LoginStatus {
        do {
            let credential = try await getCredential(for: provider)
            return try await performBackendLogin(with: credential, for: provider)
        } catch {
            throw errorMapper.mapToDomainError(from: error)
        }
    }
    
    func fetchLastLoginPlatform() async throws(LoginError) -> SocialLoginProvider {
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
                return try await finalizeExistingUser(
                    accessToken: response.accessToken,
                    refreshToken: response.refreshToken,
                    provider: provider
                )
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
                return try await finalizeExistingUser(
                    accessToken: response.accessToken,
                    refreshToken: response.refreshToken,
                    provider: provider
                )
            }
        }
    }
    
    func fetchAndStoreCurrentUser() async throws {
        let userInfo: DTO.Response.FetchUserInfo = try await loginService.request(.fetchUserInfo)
        try localStorage.save(userInfo, for: LocalStorageKeys.currentUser)
    }
    
    func finalizeExistingUser(
        accessToken: String?,
        refreshToken: String?,
        provider: SocialLoginProvider
    ) async throws -> LoginStatus {
        guard let accessToken, let refreshToken else {
            throw LoginError.noData
        }

        try await tokenService.saveToken(accessToken: accessToken, refreshToken: refreshToken)
        try? localStorage.save(provider.description, for: LocalStorageKeys.lastLoginPlatform)
        try await fetchAndStoreCurrentUser()
        return .existingUser
    }
}
