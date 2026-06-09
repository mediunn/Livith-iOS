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
    @Test("adapt는 TokenManager의 access token으로 Authorization Bearer 헤더를 삽입해야 한다")
    func adapt는_TokenManager의_access_token으로_Authorization_Bearer_헤더를_삽입해야_한다() async throws {
        let sut = AuthInterceptor(tokenManager: SpyTokenManager(accessToken: "test-access-token"))
        let request = try makeRequest()

        let adaptedRequest = try await sut.adapt(request)

        #expect(adaptedRequest.value(forHTTPHeaderField: "Authorization") == "Bearer test-access-token")
    }

    @Test("adapt는 기존 Authorization 헤더를 Bearer token으로 대체해야 한다")
    func adapt는_기존_Authorization_헤더를_Bearer_token으로_대체해야_한다() async throws {
        let sut = AuthInterceptor(tokenManager: SpyTokenManager(accessToken: "test-access-token"))
        var request = try makeRequest()
        request.setValue("Bearer stale-token", forHTTPHeaderField: "Authorization")

        let adaptedRequest = try await sut.adapt(request)

        #expect(adaptedRequest.value(forHTTPHeaderField: "Authorization") == "Bearer test-access-token")
    }

    @Test("access token 조회 실패는 NetworkError로 전달해야 한다")
    func access_token_조회_실패는_NetworkError로_전달해야_한다() async throws {
        let sut = AuthInterceptor(tokenManager: SpyTokenManager(accessTokenError: .unauthorized(message: nil)))
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

    @Test("retry는 첫 401 응답에서 refresh 후 재시도를 반환해야 한다")
    func retry는_첫_401_응답에서_refresh_후_재시도를_반환해야_한다() async throws {
        let tokenManager = SpyTokenManager(accessToken: "test-access-token")
        let sut = AuthInterceptor(tokenManager: tokenManager)
        let request = try makeRequest()

        let result = try await sut.retry(
            request,
            dueTo: .unauthorized(message: nil),
            response: try HTTPTestResponseFactory().response(statusCode: 401),
            retryCount: 0
        )

        switch result {
        case .retry:
            #expect(await tokenManager.refreshCallCount() == 1)
        case .doNotRetry:
            #expect(Bool(false))
        }
    }

    @Test("retry는 401이 아니면 refresh하지 않아야 한다")
    func retry는_401이_아니면_refresh하지_않아야_한다() async throws {
        let tokenManager = SpyTokenManager(accessToken: "test-access-token")
        let sut = AuthInterceptor(tokenManager: tokenManager)
        let request = try makeRequest()

        let result = try await sut.retry(
            request,
            dueTo: .forbidden(message: nil),
            response: try HTTPTestResponseFactory().response(statusCode: 403),
            retryCount: 0
        )

        switch result {
        case .doNotRetry:
            #expect(await tokenManager.refreshCallCount() == 0)
        case .retry:
            #expect(Bool(false))
        }
    }

    @Test("retry는 두 번째 401부터 refresh하지 않아야 한다")
    func retry는_두_번째_401부터_refresh하지_않아야_한다() async throws {
        let tokenManager = SpyTokenManager(accessToken: "test-access-token")
        let sut = AuthInterceptor(tokenManager: tokenManager)
        let request = try makeRequest()

        let result = try await sut.retry(
            request,
            dueTo: .unauthorized(message: nil),
            response: try HTTPTestResponseFactory().response(statusCode: 401),
            retryCount: 1
        )

        switch result {
        case .doNotRetry:
            #expect(await tokenManager.refreshCallCount() == 0)
        case .retry:
            #expect(Bool(false))
        }
    }

    @Test("retry의 refresh 실패는 NetworkError로 전달해야 한다")
    func retry의_refresh_실패는_NetworkError로_전달해야_한다() async throws {
        let tokenManager = SpyTokenManager(
            accessToken: "test-access-token",
            refreshError: .unauthorized(message: nil)
        )
        let sut = AuthInterceptor(tokenManager: tokenManager)
        let request = try makeRequest()

        do {
            _ = try await sut.retry(
                request,
                dueTo: .unauthorized(message: nil),
                response: try HTTPTestResponseFactory().response(statusCode: 401),
                retryCount: 0
            )
            #expect(Bool(false))
        } catch let error as NetworkError {
            guard case .unauthorized(let message) = error else {
                #expect(Bool(false))
                return
            }

            #expect(message == nil)
            #expect(await tokenManager.refreshCallCount() == 1)
        } catch {
            #expect(Bool(false))
        }
    }
}

private extension AuthInterceptorTests {
    func makeRequest() throws -> URLRequest {
        let url = try #require(URL(string: "https://api.example.com/concerts"))

        return URLRequest(url: url)
    }

    actor SpyTokenManager: TokenManager {
        private let accessTokenValue: String
        private let refreshTokenValue: String
        private let accessTokenError: NetworkError?
        private let refreshError: NetworkError?
        private var refreshCount = 0

        init(
            accessToken: String = "test-access-token",
            refreshToken: String = "test-refresh-token",
            accessTokenError: NetworkError? = nil,
            refreshError: NetworkError? = nil
        ) {
            accessTokenValue = accessToken
            refreshTokenValue = refreshToken
            self.accessTokenError = accessTokenError
            self.refreshError = refreshError
        }

        func accessToken() async throws(NetworkError) -> String {
            if let accessTokenError {
                throw accessTokenError
            }

            return accessTokenValue
        }

        func refreshToken() async throws(NetworkError) -> String {
            return refreshTokenValue
        }

        func refresh() async throws(NetworkError) {
            refreshCount += 1

            if let refreshError {
                throw refreshError
            }
        }

        func save(_ token: Token) async throws(NetworkError) {}

        func remove() async throws(NetworkError) {}

        func isTokenValid() async -> Bool {
            return true
        }

        func refreshCallCount() -> Int {
            refreshCount
        }
    }
}
