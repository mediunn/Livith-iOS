//
//  NetworkingFactory.swift
//  LivithNetworking
//
//  Created by 김진웅 on 5/27/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

public enum NetworkingFactory {
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

        #if DEBUG
        let plugins: [any NetworkPlugin] = [DebugNetworkPlugin()]
        #else
        let plugins: [any NetworkPlugin] = []
        #endif

        let client = NetworkClient(
            config: config,
            interceptor: AuthInterceptor(tokenManager: tokenManager),
            plugins: plugins
        )

        return (client: client, tokenManager: tokenManager)
    }
}
