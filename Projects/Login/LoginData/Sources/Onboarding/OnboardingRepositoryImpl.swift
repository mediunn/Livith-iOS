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
    private let localStorage: LocalKeyValueStorage
    private let tokenService: TokenService
    
    init(
        service: OnboardingService = OnboardingService(),
        errorMapper: OnboardingErrorMapper = OnboardingErrorMapper(),
        localStorage: LocalKeyValueStorage = UserDefaultsStorage(),
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
            
            // TODO: 회원가입 후, 저장해야 할 정보
            // 1. 소셜 로그인 플랫폼
            // - LocalKeyValueStorage에 tempUser.provider 저장
            try localStorage.save("\(tempUser.provider)", for: LocalStorageKeys.lastLoginPlatform)

            // 2. 응답 데이터의 User 데이터 ID를 키로 저장
            // response.user
            
            // 3. 토큰 저장
            try await tokenService.saveToken(
                accessToken: response.accessToken,
                refreshToken: response.refreshToken
            )
        } catch {
            throw errorMapper.mapToDomainError(error)
        }
    }
}
