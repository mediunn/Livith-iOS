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

typealias OnboardingService = NetworkService<OnboardingEndpoint>

final class OnboardingRepositoryImpl {
    private let service: OnboardingService
    private let errorMapper: OnboardingErrorMapper
    
    init(
        service: OnboardingService = NetworkService(),
        errorMapper: OnboardingErrorMapper = OnboardingErrorMapper()
    ) {
        self.service = service
        self.errorMapper = errorMapper
    }
}

// MARK: - OnboardingRepository

extension OnboardingRepositoryImpl: OnboardingRepository {
    func checkNicknameDuplicate(_ nickname: String) async throws(OnboardingError) -> Bool {
        do {
            let response: DTO.Response.CheckNicknameDuplicate = try await service.request(
                OnboardingEndpoint.checkNicknameDuplicate(nickname: nickname)
            )
            
            return response.available
        } catch {
            throw errorMapper.mapToDomainError(error)
        }
    }

    func signup(marketingConsent: Bool, nickname: String, tempUser: TempUser) async throws(OnboardingError) {
        let request = DTO.Request.CreateUser(
            nickname: nickname,
            marketingConsent: marketingConsent,
            providerID: tempUser.providerID,
            provider: "\(tempUser.provider)",
            email: tempUser.email
        )
        
        do {
            let response: DTO.Response.CreateUser = try await service.request(
                OnboardingEndpoint.signup(request: request)
            )
            
            // TODO: 회원가입 후, 저장해야 할 정보
            // 1. 소셜 로그인 플랫폼
            // 2. 응답 데이터의 User 데이터 ID를 키로 저장
            // 3. 토큰 저장
            
        } catch {
            throw errorMapper.mapToDomainError(error)
        }
    }
}
