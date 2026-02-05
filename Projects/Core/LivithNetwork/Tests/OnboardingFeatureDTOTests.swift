//
//  OnboardingFeatureDTOTests.swift
//  LivithNetworkTests
//
//  Created by antigravity on 2/5/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation
import Testing

@testable import LivithNetwork

struct OnboardingFeatureDTOTests {
    
    @Test("FetchUserInfo 디코딩이 정상적으로 되어야 한다")
    func fetchUserInfo_디코딩이_정상적으로_되어야_한다() throws {
        // Given
        let json = """
        {
            "id": 1,
            "interestConcertId": null,
            "provider": "kakao",
            "providerId": "test_provider_id",
            "email": null,
            "nickname": "dev",
            "marketingConsent": true,
            "preferredGenres": [
              {
                "id": 1,
                "name": "JPOP"
              },
              {
                "id": 2,
                "name": "ROCK_METAL"
              },
              {
                "id": 3,
                "name": "RAP_HIPHOP"
              }
            ],
            "preferredArtists": [
              {
                "id": 1,
                "name": "Lisa"
              },
              {
                "id": 2,
                "name": "YOASOBI"
              },
              {
                "id": 3,
                "name": "米津玄師"
              }
            ]
          }
        """.data(using: .utf8)!
        
        // When
        let result = try JSONDecoder().decode(DTO.Response.FetchUserInfo.self, from: json)
        
        // Then
        #expect(result.id == 1)
        #expect(result.nickname == "dev")
        #expect(result.preferredGenreList.count == 3)
        #expect(result.preferredArtistList.count == 3)
        
        #expect(result.preferredGenreList[0].name == "JPOP")
        #expect(result.preferredArtistList[1].name == "YOASOBI")
    }
}
