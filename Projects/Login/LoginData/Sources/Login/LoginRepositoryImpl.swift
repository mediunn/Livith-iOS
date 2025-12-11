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

typealias LoginService = NetworkService<LoginEndpoint>

final class LoginRepositoryImpl {
    private let appleLoginService: AppleLoginService
    private let kakaoLoginService: KakaoLoginService
    private let loginService: LoginService
    private let errorMapper: LoginErrorMapper
    
    init(
        appleLoginService: AppleLoginService = .init(),
        kakaoLoginService: KakaoLoginService = .init(),
        loginService: LoginService = .init(),
        errorMapper: LoginErrorMapper = .init()
    ) {
        self.appleLoginService = appleLoginService
        self.kakaoLoginService = kakaoLoginService
        self.loginService = loginService
        self.errorMapper = errorMapper
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
            let endpoint = LoginEndpoint.appleLogin(identityToken: credential.token)
            let response: DTO.Response.AppleLogin = try await loginService.request(endpoint)
            
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
            let endpoint = LoginEndpoint.kakaoLogin(accessToken: credential.token)
            let response: DTO.Response.KakaoLogin = try await loginService.request(endpoint)
            
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
