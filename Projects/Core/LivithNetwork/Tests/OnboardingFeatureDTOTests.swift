//
//  OnboardingFeatureDTOTests.swift
//  LivithNetworkTests
//
//  Created by 김진웅 on 2/5/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation
import Testing

@testable import LivithNetwork

struct OnboardingFeatureDTOTests {
    @Test("Signup 응답은 변경된 유저 DTO로 디코딩되어야 한다")
    func signup_응답은_변경된_유저_DTO로_디코딩되어야_한다() throws {
        // Given
        let json = """
        {
            "accessToken": "access-token-placeholder",
            "refreshToken": "refresh-token-placeholder",
            "user": {
                "id": 1,
                "provider": "kakao",
                "providerId": null,
                "email": null,
                "nickname": "dev",
                "marketingConsent": true,
                "hasPreferredGenre": true
            }
        }
        """.data(using: .utf8)!

        // When
        let result = try JSONDecoder().decode(DTO.Response.Signup.self, from: json)

        // Then
        #expect(result.accessToken == "access-token-placeholder")
        #expect(result.refreshToken == "refresh-token-placeholder")
        #expect(result.user.id == 1)
        #expect(result.user.provider == "kakao")
        #expect(result.user.providerID == nil)
        #expect(result.user.email == nil)
        #expect(result.user.nickname == "dev")
        #expect(result.user.marketingConsent)
        #expect(result.user.hasPreferredGenre)
    }

    @Test("FetchUserInfo 디코딩이 정상적으로 되어야 한다")
    func fetchUserInfo_디코딩이_정상적으로_되어야_한다() throws {
        // Given
        let json = """
        {
            "id": 1,
            "provider": "kakao",
            "providerId": "test_provider_id",
            "email": null,
            "nickname": "dev",
            "marketingConsent": true,
            "hasPreferredGenre": true
          }
        """.data(using: .utf8)!

        // When
        let result = try JSONDecoder().decode(DTO.Response.FetchUserInfo.self, from: json)

        // Then
        #expect(result.id == 1)
        #expect(result.nickname == "dev")
        #expect(result.providerID == "test_provider_id")
        #expect(result.marketingConsent)
        #expect(result.hasPreferredGenre)
    }

    @Test("FetchUserInfo는 providerId가 null이어도 디코딩되어야 한다")
    func fetchUserInfo는_providerId가_null이어도_디코딩되어야_한다() throws {
        // Given
        let json = """
        {
            "id": 1,
            "provider": "kakao",
            "providerId": null,
            "email": null,
            "nickname": "dev",
            "marketingConsent": true,
            "hasPreferredGenre": true
          }
        """.data(using: .utf8)!

        // When
        let result = try JSONDecoder().decode(DTO.Response.FetchUserInfo.self, from: json)

        // Then
        #expect(result.id == 1)
        #expect(result.nickname == "dev")
        #expect(result.providerID == nil)
    }
}
