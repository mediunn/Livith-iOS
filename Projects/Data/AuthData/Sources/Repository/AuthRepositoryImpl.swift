//
//  AuthRepositoryImpl.swift
//  Data
//
//  Created by 김진웅 on 2026/01/21.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation
import Domain
import LivithNetworking
import SocialAuth
import Persistence

import FirebaseMessaging

struct AuthRepositoryImpl: AuthRepository {
    private let socialAuthService: SocialAuthService
    private let onboardingService: any OnboardingService
    private let userService: any UserService
    private let notificationRepository: NotificationRepository
    private let userdefaultsStorage: UserDefaultsStorage
    private let tokenStore: any TokenStore
    private let mapper: AuthMapper = .init()
    private let errorMapper: AuthErrorMapper = .init()

    init(
        socialAuthService: SocialAuthService,
        onboardingService: any OnboardingService,
        userService: any UserService,
        notificationRepository: NotificationRepository,
        userdefaultsStorage: UserDefaultsStorage,
        tokenStore: any TokenStore
    ) {
        self.socialAuthService = socialAuthService
        self.onboardingService = onboardingService
        self.userService = userService
        self.notificationRepository = notificationRepository
        self.userdefaultsStorage = userdefaultsStorage
        self.tokenStore = tokenStore
    }
    
    func withdraw(reason: String) async throws(AuthError) {
        do {
            let _ = try await userService.withdraw(reason: reason)
        } catch {
            throw errorMapper.mapToAuthError(error)
        }
        
        await handleWithdraw()
    }
    
    func logout() async throws(AuthError) {
        do {
            let refreshToken = try await tokenStore.fetch().refreshToken
            let request = DTO.Request.RequestLogout(refreshToken: refreshToken)
            let _ = try await userService.logout(refreshToken: refreshToken)
        } catch {
            throw errorMapper.mapToAuthError(error)
        }
        
        await handleLogout()
    }
    
    func checkNicknameDuplicate(nickname: String) async throws(AuthError) -> Bool {
        do {
            let response: DTO.Response.CheckNicknameDuplicate = try await userService.checkNicknameDuplicate(nickname: nickname)
            return mapper.toDomain(from: response)
        } catch {
            throw errorMapper.mapToAuthError(error)
        }
    }
    
    func signup(_ signup: SignupInfo) async throws(AuthError) {
        do {
            let request: DTO.Request.Signup = .init(
                nickname: signup.nickname.value,
                preferredArtistIDList: signup.preferredArtistIDList,
                preferredGenreIDList: signup.preferredGenreIDList,
                email: signup.email,
                provider: signup.provider.description,
                providerID: signup.providerID,
                marketingConsent: signup.isMarketingAgreed
            )
            let response: DTO.Response.Signup = try await onboardingService.signup(request)
            
            let tempUser = TempUser(
                provider: signup.provider,
                providerID: signup.providerID,
                email: signup.email
            )
            
            try await handleSignup(response: response, tempUser: tempUser)
        } catch {
            throw errorMapper.mapToAuthError(error)
        }
    }
    
    func kakaoLogin() async throws(AuthError) -> LoginStatus {
        do {
            let credential = try await getCredential(for: .kakao)
            let response: DTO.Response.KakaoLogin = try await onboardingService.kakaoLogin(accessToken: credential.token)
            return try await handleLoginResponse(response, provider: .kakao)
        } catch {
            throw mapLoginError(error)
        }
    }
    
    func appleLogin() async throws(AuthError) -> LoginStatus {
        do {
            let credential = try await getCredential(for: .apple)
            let response: DTO.Response.AppleLogin = try await onboardingService.appleLogin(identityToken: credential.token)
            return try await handleLoginResponse(response, provider: .apple)
        } catch {
            throw mapLoginError(error)
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
    func mapLoginError(_ error: Error) -> AuthError {
        // Login 403 should always be treated as recent withdrawal regardless of message text.
        if let networkError = error as? NetworkError, case .forbidden = networkError {
            return .recentlyWithdrawn
        }
        return errorMapper.mapToAuthError(error)
    }

    func handleWithdraw() async {
        await handleLogout()
        userdefaultsStorage.remove(for: .lastLoginPlatform)
    }
    
    func handleLogout() async {
        await deleteFCMToken()
        try? await tokenStore.remove()
        userdefaultsStorage.remove(for: .currentUser)
    }

    func registerFCMToken() async {
        guard let fcmToken = try? await Messaging.messaging().token() else { return }
        try? await notificationRepository.registerFCMToken(fcmToken)
    }

    func deleteFCMToken() async {
        guard let fcmToken = try? await Messaging.messaging().token() else { return }
        try? await notificationRepository.deleteFCMToken(fcmToken)
    }
    
    func handleSignup(response: DTO.Response.Signup, tempUser: TempUser) async throws {
        try await tokenStore.save(Token(
            accessToken: response.accessToken,
            refreshToken: response.refreshToken,
            refreshTokenIssuedAt: Date()
        ))

        let user = mapper.toDomain(from: response.user)
        try? userdefaultsStorage.save(user, for: .currentUser)
        try? userdefaultsStorage.save(tempUser.provider.description, for: .lastLoginPlatform)

        await registerFCMToken()
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

            try await tokenStore.save(Token(accessToken: accessToken, refreshToken: refreshToken, refreshTokenIssuedAt: Date()))

            try? userdefaultsStorage.save(provider.description, for: .lastLoginPlatform)

            let userInfoResponse: DTO.Response.FetchUserInfo = try await onboardingService.fetchUserInfo()
            let user = mapper.toDomain(from: userInfoResponse)
            try? userdefaultsStorage.save(user, for: .currentUser)

            await registerFCMToken()

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
