//
//  OnboardingRepositoryImpl.swift
//  OnboardingData
//
//  Created by 김진웅 on 11/10/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import Foundation

import LivithNetwork
import OnboardingDomain

final class OnboardingRepositoryImpl {
    private let service: NetworkServiceProtocol
    private let errorMapper: OnboardingErrorMapper
    
    init(
        service: NetworkServiceProtocol = NetworkService(),
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
            let response: BaseResponse<DTO.Response.CheckNicknameDuplicate> = try await service.request(
                OnboardingEndpoint.checkNicknameDuplicate(nickname: nickname)
            )
            
            guard let data = response.data else {
                throw OnboardingError.unknown
            }
            
            return data.available
            
        } catch let error as OnboardingError {
            throw error
        } catch let error as NetworkError {
            throw errorMapper.mapToOnboardingError(error)
        } catch {
            throw OnboardingError.unknown
        }
    }

    func signup(nickname: String) async throws(OnboardingError) {
        // TODO: OAuth provider 정보를 받아올 수 있는 구조로 개선 필요
        // 현재는 임시로 하드코딩된 값 사용
        let request = DTO.Request.CreateUser(
            nickname: nickname,
            marketingConsent: false,
            userID: "",
            providerID: "",
            provider: "",
            email: nil
        )
        
        do {
            let response: BaseResponse<DTO.Response.CreateUser> = try await service.request(
                OnboardingEndpoint.signup(request: request, client: "mobile")
            )
            
            if let error = response.error {
                throw OnboardingError.signupFailed(reason: error)
            }
            
            // TODO: 토큰 저장 로직 추가 필요
            // response.data?.accessToken
            // response.data?.refreshToken
            
        } catch let error as OnboardingError {
            throw error
        } catch let error as NetworkError {
            throw errorMapper.mapToOnboardingError(error)
        } catch {
            throw OnboardingError.unknown
        }
    }
}
