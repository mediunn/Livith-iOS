//
//  OnboardingRepositoryImpl.swift
//  LoginData
//
//  Created by 김진웅 on 11/10/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import Foundation

import LivithNetwork
import LoginDomain
import Persistence

final class OnboardingRepositoryImpl {
    private let service: OnboardingService
    private let errorMapper: OnboardingErrorMapper
    private let localStorage: UserDefaultsStorage
    private let tokenService: TokenService
    
    init(
        service: OnboardingService = OnboardingService(),
        errorMapper: OnboardingErrorMapper = OnboardingErrorMapper(),
        localStorage: UserDefaultsStorage = UserDefaultsStorage(defaults: UserDefaults(suiteName: UserDefaultsStorage.appGroupID) ?? .standard),
        tokenService: TokenService = TokenServiceImpl()
    ) {
        self.service = service
        self.errorMapper = errorMapper
        self.localStorage = localStorage
        self.tokenService = tokenService
    }
}

// MARK: - OnboardingRepository

extension OnboardingRepositoryImpl: OnboardingRepository {
    func checkNicknameDuplicate(_ nickname: String) async throws(OnboardingError) -> Bool {
        do {
            let response: DTO.Response.CheckNicknameDuplicate = try await service.request(.checkNicknameDuplicate(nickname: nickname))
            
            return response.available
        } catch {
            throw errorMapper.mapToDomainError(error)
        }
    }

    func signup(marketingConsent: Bool, nickname: String, tempUser: TempUser) async throws(OnboardingError) {
        do {
            let response: DTO.Response.Signup = try await service.request(
                .signup(
                    nickname: nickname,
                    marketingConsent: marketingConsent,
                    providerID: tempUser.providerID,
                    provider: "\(tempUser.provider)",
                    email: tempUser.email
                )
            )
            
            try? localStorage.save("\(tempUser.provider)", for: .lastLoginPlatform)

            try localStorage.save(response.user, for: .currentUser)

            try await tokenService.saveToken(
                accessToken: response.accessToken,
                refreshToken: response.refreshToken
            )
        } catch {
            throw errorMapper.mapToDomainError(error)
        }
    }
}
