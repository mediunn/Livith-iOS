//
//  TokenExpirationPolicyTests.swift
//  LivithNetworkingTests
//
//  Created by 김진웅 on 5/11/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

import Testing

@testable import LivithNetworking

@Suite("TokenExpirationPolicy")
struct TokenExpirationPolicyTests {
    @Test("refresh token 발급 후 3일 초과 시 만료로 판단해야 한다")
    func refresh_token_발급_후_3일_초과_시_만료로_판단해야_한다() {
        let sut = TokenExpirationPolicy.default
        let issuedAt = Date(timeIntervalSince1970: 1_700_000_000)
        let now = issuedAt.addingTimeInterval(3 * 24 * 60 * 60 + 1)

        #expect(sut.isRefreshTokenExpired(issuedAt: issuedAt, now: now))
    }

    @Test("refresh token 발급 후 3일 이하이면 만료가 아니어야 한다")
    func refresh_token_발급_후_3일_이하이면_만료가_아니어야_한다() {
        let sut = TokenExpirationPolicy.default
        let issuedAt = Date(timeIntervalSince1970: 1_700_000_000)
        let now = issuedAt.addingTimeInterval(3 * 24 * 60 * 60)

        #expect(!sut.isRefreshTokenExpired(issuedAt: issuedAt, now: now))
    }

    @Test("기준 시각이 발급 시각보다 이전이면 만료가 아니어야 한다")
    func 기준_시각이_발급_시각보다_이전이면_만료가_아니어야_한다() {
        let sut = TokenExpirationPolicy.default
        let issuedAt = Date(timeIntervalSince1970: 1_700_000_000)
        let now = issuedAt.addingTimeInterval(-1)

        #expect(!sut.isRefreshTokenExpired(issuedAt: issuedAt, now: now))
    }
}
