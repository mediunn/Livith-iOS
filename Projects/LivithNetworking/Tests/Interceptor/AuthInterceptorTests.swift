//
//  AuthInterceptorTests.swift
//  LivithNetworkingTests
//
//  Created by 김진웅 on 5/11/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

import Testing

@testable import LivithNetworking

@Suite("AuthInterceptor")
struct AuthInterceptorTests {
    @Test("adapt는 Authorization Bearer 헤더를 삽입해야 한다")
    func adapt는_Authorization_Bearer_헤더를_삽입해야_한다() async throws {
        let sut = AuthInterceptor(tokenStore: StubTokenStore(token: makeToken()))
        let request = try makeRequest()

        let adaptedRequest = try await sut.adapt(request)

        #expect(adaptedRequest.value(forHTTPHeaderField: "Authorization") == "Bearer test-access-token")
    }

    @Test("adapt는 기존 Authorization 헤더를 Bearer token으로 대체해야 한다")
    func adapt는_기존_Authorization_헤더를_Bearer_token으로_대체해야_한다() async throws {
        let sut = AuthInterceptor(tokenStore: StubTokenStore(token: makeToken()))
        var request = try makeRequest()
        request.setValue("Bearer stale-token", forHTTPHeaderField: "Authorization")

        let adaptedRequest = try await sut.adapt(request)

        #expect(adaptedRequest.value(forHTTPHeaderField: "Authorization") == "Bearer test-access-token")
    }

    @Test("token 조회 실패는 unauthorized로 매핑해야 한다")
    func token_조회_실패는_unauthorized로_매핑해야_한다() async throws {
        let sut = AuthInterceptor(tokenStore: StubTokenStore(error: .noToken))
        let request = try makeRequest()

        do {
            _ = try await sut.adapt(request)
            #expect(Bool(false))
        } catch .unauthorized(let message) {
            #expect(message == nil)
        } catch {
            #expect(Bool(false))
        }
    }

    @Test("retry는 현재 재시도하지 않아야 한다")
    func retry는_현재_재시도하지_않아야_한다() async throws {
        let sut = AuthInterceptor(tokenStore: StubTokenStore(token: makeToken()))
        let request = try makeRequest()

        let result = await sut.retry(
            request,
            dueTo: .unauthorized(message: nil),
            response: nil,
            retryCount: 0
        )

        switch result {
        case .doNotRetry:
            #expect(Bool(true))
        case .retry:
            #expect(Bool(false))
        }
    }
}

private extension AuthInterceptorTests {
    func makeRequest() throws -> URLRequest {
        let url = try #require(URL(string: "https://api.example.com/concerts"))

        return URLRequest(url: url)
    }

    func makeToken() -> Token {
        Token(
            accessToken: "test-access-token",
            refreshToken: "test-refresh-token",
            refreshTokenIssuedAt: Date(timeIntervalSince1970: 1_700_000_000)
        )
    }

    struct StubTokenStore: TokenStore {
        let token: Token?
        let error: TokenError?

        init(
            token: Token? = nil,
            error: TokenError? = nil
        ) {
            self.token = token
            self.error = error
        }

        func save(_ token: Token) async throws(TokenError) {}

        func fetch() async throws(TokenError) -> Token {
            if let error {
                throw error
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
    }
}
