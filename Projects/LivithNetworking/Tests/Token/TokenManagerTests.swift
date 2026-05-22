//
//  TokenManagerTests.swift
//  LivithNetworkingTests
//
//  Created by 김진웅 on 5/13/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

import Testing

@testable import LivithNetworking

@Suite("TokenManager")
struct TokenManagerTests {
    @Test("accessToken은 저장된 access token을 반환해야 한다")
    func accessToken은_저장된_access_token을_반환해야_한다() async throws {
        let tokenStore = SpyTokenStore(token: makeStoredToken())
        let sut = makeSUT(tokenStore: tokenStore)

        let accessToken = try await sut.accessToken()

        #expect(accessToken == "stored-access-token")
        #expect(await tokenStore.fetchCallCount() == 1)
    }

    @Test("accessToken의 저장 토큰 조회 실패는 unauthorized로 매핑해야 한다")
    func accessToken의_저장_토큰_조회_실패는_unauthorized로_매핑해야_한다() async throws {
        let tokenStore = SpyTokenStore(fetchError: .noToken)
        let sut = makeSUT(tokenStore: tokenStore)

        do {
            _ = try await sut.accessToken()
            #expect(Bool(false))
        } catch .unauthorized(let message) {
            #expect(message == nil)
        } catch {
            #expect(Bool(false))
        }
    }

    @Test("refresh는 저장된 refresh token으로 새 토큰을 요청하고 저장해야 한다")
    func refresh는_저장된_refresh_token으로_새_토큰을_요청하고_저장해야_한다() async throws {
        let tokenStore = SpyTokenStore(token: makeStoredToken())
        let tokenRefreshService = SpyTokenRefreshService(token: makeRefreshedToken())
        let sut = makeSUT(tokenStore: tokenStore, tokenRefreshService: tokenRefreshService)

        try await sut.refresh()

        #expect(await tokenRefreshService.refreshTokenList() == ["stored-refresh-token"])
        #expect(await tokenStore.savedTokenList() == [makeRefreshedToken()])
    }

    @Test("refresh의 저장 토큰 조회 실패는 unauthorized로 매핑해야 한다")
    func refresh의_저장_토큰_조회_실패는_unauthorized로_매핑해야_한다() async throws {
        let tokenStore = SpyTokenStore(fetchError: .noToken)
        let tokenRefreshService = SpyTokenRefreshService(token: makeRefreshedToken())
        let sut = makeSUT(tokenStore: tokenStore, tokenRefreshService: tokenRefreshService)

        do {
            try await sut.refresh()
            #expect(Bool(false))
        } catch .unauthorized(let message) {
            #expect(message == nil)
            #expect(await tokenRefreshService.refreshTokenList().isEmpty)
        } catch {
            #expect(Bool(false))
        }
    }

    @Test("refresh 실패 시 새 토큰을 저장하지 않고 NetworkError를 전달해야 한다")
    func refresh_실패_시_새_토큰을_저장하지_않고_NetworkError를_전달해야_한다() async throws {
        let tokenStore = SpyTokenStore(token: makeStoredToken())
        let tokenRefreshService = SpyTokenRefreshService(error: .unauthorized(message: "expired"))
        let sut = makeSUT(tokenStore: tokenStore, tokenRefreshService: tokenRefreshService)

        do {
            try await sut.refresh()
            #expect(Bool(false))
        } catch .unauthorized(let message) {
            #expect(message == "expired")
            #expect(await tokenStore.savedTokenList().isEmpty)
        } catch {
            #expect(Bool(false))
        }
    }

    @Test("refresh 저장 실패는 unknown으로 매핑해야 한다")
    func refresh_저장_실패는_unknown으로_매핑해야_한다() async throws {
        let tokenStore = SpyTokenStore(token: makeStoredToken(), saveError: .saveFailed)
        let tokenRefreshService = SpyTokenRefreshService(token: makeRefreshedToken())
        let sut = makeSUT(tokenStore: tokenStore, tokenRefreshService: tokenRefreshService)

        do {
            try await sut.refresh()
            #expect(Bool(false))
        } catch .unknown(let error) {
            guard case .saveFailed = error as? TokenError else {
                Issue.record("저장 실패 원본 TokenError를 보존해야 한다")
                return
            }
        } catch {
            #expect(Bool(false))
        }
    }

    @Test("refresh 실패(unauthorized) 시 onRefreshTokenExpired 클로저를 호출해야 한다")
    func refresh_실패_unauthorized_시_onRefreshTokenExpired_클로저를_호출해야_한다() async throws {
        // Given
        let tokenStore = SpyTokenStore(token: makeStoredToken())
        let tokenRefreshService = SpyTokenRefreshService(error: .unauthorized(message: "expired"))
        nonisolated(unsafe) var expiredCalled = false
        let sut = makeSUT(
            tokenStore: tokenStore,
            tokenRefreshService: tokenRefreshService,
            onRefreshTokenExpired: { expiredCalled = true }
        )

        // When
        do {
            try await sut.refresh()
        } catch {
            // Expected: NetworkError 발생
        }

        // Then
        #expect(expiredCalled == true)
    }

    @Test("refresh 성공 시 onRefreshTokenExpired 클로저를 호출하지 않아야 한다")
    func refresh_성공_시_onRefreshTokenExpired_클로저를_호출하지_않아야_한다() async throws {
        // Given
        let tokenStore = SpyTokenStore(token: makeStoredToken())
        let tokenRefreshService = SpyTokenRefreshService(token: makeRefreshedToken())
        nonisolated(unsafe) var expiredCalled = false
        let sut = makeSUT(
            tokenStore: tokenStore,
            tokenRefreshService: tokenRefreshService,
            onRefreshTokenExpired: { expiredCalled = true }
        )

        // When
        try await sut.refresh()

        // Then
        #expect(expiredCalled == false)
    }

    @Test("동시 refresh 호출은 하나의 전체 refresh 흐름을 공유해야 한다")
    func 동시_refresh_호출은_하나의_전체_refresh_흐름을_공유해야_한다() async throws {
        let tokenStore = SpyTokenStore(token: makeStoredToken())
        let tokenRefreshService = SpyTokenRefreshService(
            token: makeRefreshedToken(),
            delayNanoseconds: 100_000_000
        )
        let sut = makeSUT(tokenStore: tokenStore, tokenRefreshService: tokenRefreshService)

        async let first: Void = sut.refresh()
        async let second: Void = sut.refresh()
        _ = try await [first, second]

        #expect(await tokenStore.fetchCallCount() == 1)
        #expect(await tokenRefreshService.refreshTokenList() == ["stored-refresh-token"])
        #expect(await tokenStore.savedTokenList() == [makeRefreshedToken()])
    }
}

private extension TokenManagerTests {
    func makeSUT(
        tokenStore: SpyTokenStore,
        tokenRefreshService: SpyTokenRefreshService? = nil,
        onRefreshTokenExpired: (@Sendable () -> Void)? = nil
    ) -> TokenManagerImpl {
        TokenManagerImpl(
            tokenStore: tokenStore,
            tokenRefreshService: tokenRefreshService ?? SpyTokenRefreshService(token: makeRefreshedToken()),
            onRefreshTokenExpired: onRefreshTokenExpired
        )
    }

    func makeStoredToken() -> Token {
        Token(
            accessToken: "stored-access-token",
            refreshToken: "stored-refresh-token",
            refreshTokenIssuedAt: Date(timeIntervalSince1970: 1_700_000_000)
        )
    }

    func makeRefreshedToken() -> Token {
        Token(
            accessToken: "refreshed-access-token",
            refreshToken: "refreshed-refresh-token",
            refreshTokenIssuedAt: Date(timeIntervalSince1970: 1_700_001_000)
        )
    }

    actor SpyTokenStore: TokenStore {
        private let token: Token?
        private let fetchError: TokenError?
        private let saveError: TokenError?
        private var fetchCount = 0
        private var savedTokenListValue: [Token] = []

        init(
            token: Token? = nil,
            fetchError: TokenError? = nil,
            saveError: TokenError? = nil
        ) {
            self.token = token
            self.fetchError = fetchError
            self.saveError = saveError
        }

        func save(_ token: Token) async throws(TokenError) {
            if let saveError {
                throw saveError
            }

            savedTokenListValue.append(token)
        }

        func fetch() async throws(TokenError) -> Token {
            fetchCount += 1

            if let fetchError {
                throw fetchError
            }

            guard let token else {
                throw .noToken
            }

            return token
        }

        func remove() async throws(TokenError) {}

        func isRefreshTokenExpired() async -> Bool {
            false
        }

        func fetchCallCount() -> Int {
            fetchCount
        }

        func savedTokenList() -> [Token] {
            savedTokenListValue
        }
    }

    actor SpyTokenRefreshService: TokenRefreshService {
        private let token: Token?
        private let error: NetworkError?
        private let delayNanoseconds: UInt64
        private var refreshTokenListValue: [String] = []

        init(
            token: Token? = nil,
            error: NetworkError? = nil,
            delayNanoseconds: UInt64 = 0
        ) {
            self.token = token
            self.error = error
            self.delayNanoseconds = delayNanoseconds
        }

        func refresh(with refreshToken: String) async throws(NetworkError) -> Token {
            refreshTokenListValue.append(refreshToken)

            if delayNanoseconds > 0 {
                do {
                    try await Task.sleep(nanoseconds: delayNanoseconds)
                } catch {
                    throw .cancelled
                }
            }

            if let error {
                throw error
            }

            guard let token else {
                throw .invalidResponse
            }

            return token
        }

        func refreshTokenList() -> [String] {
            refreshTokenListValue
        }
    }
}
