//
//  NetworkClientBuilder.swift
//  LivithNetworking
//
//  Created by 김진웅 on 5/27/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

public enum NetworkClientBuilder {
    public static func build(
        config: NetworkConfig,
        onAuthenticationExpired: @Sendable @escaping () -> Void = {}
    ) -> (client: NetworkClient, tokenManager: any TokenManager) {
        let tokenStore = KeychainTokenStore()
        let refreshClient = NetworkClient(config: config, interceptor: nil)

        let tokenRefreshService = TokenRefreshServiceImpl(
            networkClient: refreshClient
        )

        let tokenManager = TokenManagerImpl(
            tokenStore: tokenStore,
            tokenRefreshService: tokenRefreshService,
            onRefreshTokenExpired: onAuthenticationExpired
        )

        let client = NetworkClient(
            config: config,
            interceptor: AuthInterceptor(tokenManager: tokenManager),
            plugins: [DebugNetworkPlugin()]
        )

        return (client: client, tokenManager: tokenManager)
    }
}
