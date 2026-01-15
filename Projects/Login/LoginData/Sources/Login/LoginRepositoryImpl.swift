//
//  LoginRepositoryImpl.swift
//  LoginData
//
//  Created by 김진웅 on 12/5/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import Foundation

import SocialAuth
import LivithNetwork
import LoginDomain
import Persistence

final class LoginRepositoryImpl {
    private let socialAuthService: SocialAuthService
    private let loginService: OnboardingService
    private let localStorage: UserDefaultsStorage
    private let tokenService: TokenService
    private let errorMapper: LoginErrorMapper = .init()
    
    init(
        socialAuthService: SocialAuthService = .init(),
        loginService: OnboardingService = .init(),
        localStorage: UserDefaultsStorage = UserDefaultsStorage(defaults: UserDefaults(suiteName: UserDefaultsStorage.appGroupID) ?? .standard),
        tokenService: TokenService = TokenServiceImpl()
    ) {
        self.socialAuthService = socialAuthService
        self.loginService = loginService
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
            let value: String = try localStorage.fetch(for: .lastLoginPlatform)
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
    func getCredential(for provider: SocialLoginProvider) async throws(SocialAuthError) -> SocialAuthCredential {
        return try await socialAuthService.signIn(with: provider.authVendor)
    }
    
    func performBackendLogin(with credential: SocialAuthCredential, for provider: SocialLoginProvider) async throws -> LoginStatus {
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
    
    func fetchAndStoreCurrentUser() async throws -> String {
        let userInfo: DTO.Response.FetchUserInfo = try await loginService.request(.fetchUserInfo)
        try localStorage.save(userInfo, for: .currentUser)
        return userInfo.nickname
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
        try? localStorage.save(provider.description, for: .lastLoginPlatform)
        let nickname = try await fetchAndStoreCurrentUser()
        return .existingUser(nickname: nickname)
    }
}
