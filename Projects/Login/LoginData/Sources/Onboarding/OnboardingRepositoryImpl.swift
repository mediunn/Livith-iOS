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
            throw errorMapper.mapToOnboardingError(error)
        }
    }

    func signup(nickname: String) async throws(OnboardingError) {
        // TODO: OAuth provider 정보를 받아올 수 있는 구조로 개선 필요
        // 현재는 임시로 하드코딩된 값 사용
        let request = DTO.Request.CreateUser(
            nickname: nickname,
            marketingConsent: false,
            providerID: "",
            provider: "",
            email: nil
        )
        
        do {
            let response: DTO.Response.CreateUser = try await service.request(
                OnboardingEndpoint.signup(request: request, client: "mobile")
            )
            
            // TODO: 토큰 저장 로직 추가 필요
            // response.data?.accessToken
            // response.data?.refreshToken
        } catch {
            throw errorMapper.mapToOnboardingError(error)
        }
    }
}
