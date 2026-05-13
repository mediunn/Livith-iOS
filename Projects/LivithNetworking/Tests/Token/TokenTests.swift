//
//  TokenTests.swift
//  LivithNetworkingTests
//
//  Created by 김진웅 on 5/11/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

import Testing

@testable import LivithNetworking

@Suite("Token")
struct TokenTests {
    @Test("Token은 accessToken, refreshToken, refreshTokenIssuedAt을 보관하고 비교할 수 있어야 한다")
    func Token은_토큰_값과_발급_시각을_보관하고_비교할_수_있어야_한다() {
        let issuedAt = Date(timeIntervalSince1970: 1_700_000_000)
        let token = Token(
            accessToken: "access",
            refreshToken: "refresh",
            refreshTokenIssuedAt: issuedAt
        )
        let sameToken = Token(
            accessToken: "access",
            refreshToken: "refresh",
            refreshTokenIssuedAt: issuedAt
        )

        #expect(token.accessToken == "access")
        #expect(token.refreshToken == "refresh")
        #expect(token.refreshTokenIssuedAt == issuedAt)
        #expect(token == sameToken)
    }

    @Test("TokenError는 저장소 실패 케이스별 한글 설명을 제공해야 한다")
    func TokenError는_저장소_실패_케이스별_한글_설명을_제공해야_한다() {
        let errorList: [TokenError] = [
            .saveFailed,
            .loadFailed,
            .deleteFailed,
            .noToken,
            .encodingFailed,
            .decodingFailed,
            .unknown
        ]

        for error in errorList {
            #expect(error.errorDescription?.isEmpty == false)
        }
    }
}
