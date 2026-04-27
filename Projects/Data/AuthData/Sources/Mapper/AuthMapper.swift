//
//  AuthMapper.swift
//  Data
//
//  Created by 김진웅 on 1/21/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

import Domain
import LivithNetwork

struct AuthMapper {
    func toDomain(from response: DTO.Response.CheckNicknameDuplicate) -> Bool {
        return response.available
    }
    
    func toDomain(from response: DTO.Response.FetchUserInfo) -> User {
        return User(
            id: response.id,
            // TODO: LIVD-357 User 모델에서 interestConcertID를 제거하고 관심 콘서트 상태를 별도 API/모델로 분리한다.
            interestConcertID: nil,
            provider: response.provider,
            providerID: response.providerID,
            email: response.email,
            nickname: response.nickname,
            hasPreferences: response.hasPreferredGenre,
            authority: UserAuthority(deviceNotification: true, marketingConsent: response.marketingConsent)
        )
    }
}
