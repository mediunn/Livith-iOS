//
//  AuthInterceptor.swift
//  LivithNetworking
//
//  Created by 김진웅 on 5/11/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

struct AuthInterceptor: RequestInterceptor {
    private let tokenManager: any TokenManager

    init(tokenManager: any TokenManager) {
        self.tokenManager = tokenManager
    }

    init(
        config: NetworkConfig,
        tokenStore: any TokenStore = KeychainTokenStore()
    ) {
        self.init(
            tokenManager: TokenManagerImpl(
                tokenStore: tokenStore,
                tokenRefreshService: TokenRefreshServiceImpl(
                    networkClient: NetworkClient(config: config)
                )
            )
        )
    }

    func adapt(
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

    func retry(
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
