//
//  AuthInterceptor.swift
//  LivithNetworking
//
//  Created by 김진웅 on 5/11/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

public struct AuthInterceptor: RequestInterceptor {
    private let tokenManager: any TokenManager

    public init(tokenManager: any TokenManager) {
        self.tokenManager = tokenManager
    }

    public init(
        config: NetworkConfig,
        tokenStore: any TokenStore = KeychainTokenStore()
    ) {
        self.init(
            tokenManager: TokenManagerImpl(
                tokenStore: tokenStore,
                tokenRefreshService: TokenRefreshServiceImpl(config: config)
            )
        )
    }

    public func adapt(
        _ request: URLRequest
    ) async throws(NetworkError) -> URLRequest {
        let accessToken = try await tokenManager.accessToken()

        var adaptedRequest = request
        adaptedRequest.setValue(
            "Bearer \(accessToken)",
            forHTTPHeaderField: "Authorization"
        )

        return adaptedRequest
    }

    public func retry(
        _ request: URLRequest,
        dueTo error: NetworkError,
        response: HTTPURLResponse?,
        retryCount: Int
    ) async throws(NetworkError) -> RetryResult {
        guard retryCount == 0,
              response?.statusCode == 401
        else {
            return .doNotRetry
        }

        try await tokenManager.refresh()
        return .retry
    }
}
