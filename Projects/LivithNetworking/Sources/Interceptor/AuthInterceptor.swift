//
//  AuthInterceptor.swift
//  LivithNetworking
//
//  Created by 김진웅 on 5/11/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

public struct AuthInterceptor: RequestInterceptor {
    private let tokenStore: any TokenStore

    public init(tokenStore: any TokenStore = KeychainTokenStore()) {
        self.tokenStore = tokenStore
    }

    public func adapt(
        _ request: URLRequest
    ) async throws(NetworkError) -> URLRequest {
        let token: Token
        do {
            token = try await tokenStore.fetch()
        } catch {
            throw .unauthorized(message: nil)
        }

        var adaptedRequest = request
        adaptedRequest.setValue(
            "Bearer \(token.accessToken)",
            forHTTPHeaderField: "Authorization"
        )

        return adaptedRequest
    }

    public func retry(
        _ request: URLRequest,
        dueTo error: NetworkError,
        response: HTTPURLResponse?,
        retryCount: Int
    ) async -> RetryResult {
        .doNotRetry
    }
}
