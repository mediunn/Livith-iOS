//
//  AuthRepositoryImpl.swift
//  Data
//
//  Created by 김진웅 on 2026/01/21.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

import Domain
import LivithNetwork
import SocialAuth
import Persistence

struct AuthRepositoryImpl: AuthRepository {
    private let socialAuthService: SocialAuthService
    private let onboardingService: OnboardingService
    private let userService: UserService
    private let userdefaultsStorage: UserDefaultsStorage
    private let tokenService: TokenService
    private let mapper: AuthMapper
    private let errorMapper: AuthErrorMapper
    
    func withdraw(reason: String) async throws(AuthError) {
        do {
            let request = DTO.Request.DeleteUser(reason: reason)
            let _: DTO.Response.DeleteUser = try await userService.request(.withdraw(request: request))
        } catch {
            throw errorMapper.mapToAuthError(error)
        }
        
        await handleWithdraw()
    }
    
    func logout() async throws(AuthError) {
        do {
            let refreshToken = try await tokenService.getRefreshToken()
            let request = DTO.Request.RequestLogout(refreshToken: refreshToken)
            let _: DTO.Response.RequestLogout = try await userService.request(.logout(request: request))
        } catch {
            throw errorMapper.mapToAuthError(error)
        }
        
        await handleLogout()
    }
    
    func checkNicknameDuplicate(nickname: String) async throws(AuthError) -> Bool {
        do {
            let response: DTO.Response.CheckNicknameDuplicate = try await userService.request(
                .checkNicknameDuplicate(nickname: nickname)
            )
            return mapper.toDomain(from: response)
        } catch {
            throw errorMapper.mapToAuthError(error)
        }
    }
    
    func signup(tempUser: TempUser, marketingConsent: Bool, nickname: String) async throws(AuthError) {
        do {
            let response: DTO.Response.Signup = try await onboardingService.request(
                .signup(
                    nickname: nickname,
                    marketingConsent: marketingConsent,
                    providerID: tempUser.providerID,
                    provider: tempUser.provider.description,
                    email: tempUser.email
                )
            )
            
            try await handleSignup(response: response, tempUser: tempUser)
        } catch {
            throw errorMapper.mapToAuthError(error)
        }
    }
    
    func kakaoLogin() async throws(AuthError) -> LoginStatus {
        do {
            let credential = try await getCredential(for: .kakao)
            let response: DTO.Response.KakaoLogin = try await onboardingService.request(
                .kakaoLogin(accessToken: credential.token)
            )
            return try await handleLoginResponse(response, provider: .kakao)
        } catch {
            throw errorMapper.mapToAuthError(error)
        }
    }
    
    func appleLogin() async throws(AuthError) -> LoginStatus {
        do {
            let credential = try await getCredential(for: .apple)
            let response: DTO.Response.AppleLogin = try await onboardingService.request(
                .appleLogin(identityToken: credential.token)
            )
            return try await handleLoginResponse(response, provider: .apple)
        } catch {
            throw errorMapper.mapToAuthError(error)
        }
    }
    
    func fetchLastLoginPlatform() async throws(AuthError) -> SocialLoginProvider {
        do {
            let value: String = try userdefaultsStorage.fetch(for: .lastLoginPlatform)
            switch value {
            case "apple":
                return .apple
            case "kakao":
                return .kakao
            default:
                throw AuthError.invalidResponse
            }
        } catch {
            throw AuthError.invalidResponse
        }
    }
}

// MARK: - Helpers

private extension AuthRepositoryImpl {
    func handleWithdraw() async {
        await handleLogout()
        userdefaultsStorage.remove(for: .lastLoginPlatform)
    }
    
    func handleLogout() async {
        try? await tokenService.removeToken()
        userdefaultsStorage.remove(for: .currentUser)
    }
    
    func handleSignup(response: DTO.Response.Signup, tempUser: TempUser) async throws {
        try await tokenService.saveToken(
            accessToken: response.accessToken,
            refreshToken: response.refreshToken
        )
        
        let user = mapper.toDomain(from: response.user)
        try? userdefaultsStorage.save(user, for: .currentUser)
        try? userdefaultsStorage.save(tempUser.provider.description, for: .lastLoginPlatform)
    }
    
    func getCredential(for provider: SocialLoginProvider) async throws -> SocialAuthCredential {
        let vendor: SocialAuthVendor = switch provider {
        case .apple: .apple
        case .kakao: .kakao
        }
        return try await socialAuthService.signIn(with: vendor)
    }
    
    func handleLoginResponse<T: LoginResponseProtocol>(_ response: T, provider: SocialLoginProvider) async throws -> LoginStatus {
        if response.isNewUser {
            guard let providerID = response.tempUserProviderID else {
                throw AuthError.invalidResponse
            }
            
            let tempUser = TempUser(provider: provider, providerID: providerID, email: response.tempUserEmail)
            return .newUser(tempUser: tempUser)
        } else {
            guard let accessToken = response.accessToken, let refreshToken = response.refreshToken else {
                throw AuthError.invalidResponse
            }
            
            try await tokenService.saveToken(accessToken: accessToken, refreshToken: refreshToken)
            
            try? userdefaultsStorage.save(provider.description, for: .lastLoginPlatform)
            
            let userInfoResponse: DTO.Response.FetchUserInfo = try await onboardingService.request(.fetchUserInfo)
            let user = mapper.toDomain(from: userInfoResponse)
            try? userdefaultsStorage.save(user, for: .currentUser)
            
            return .existingUser(nickname: user.nickname)
        }
    }
}

// MARK: - LoginResponseProtocol

private protocol LoginResponseProtocol {
    var isNewUser: Bool { get }
    var accessToken: String? { get }
    var refreshToken: String? { get }
    var tempUserProviderID: String? { get }
    var tempUserEmail: String? { get }
}

extension DTO.Response.KakaoLogin: LoginResponseProtocol {
    var tempUserProviderID: String? { tempUser?.providerID }
    var tempUserEmail: String? { nil }
}

extension DTO.Response.AppleLogin: LoginResponseProtocol {
    var tempUserProviderID: String? { tempUser?.providerID }
    var tempUserEmail: String? { tempUser?.email }
}
