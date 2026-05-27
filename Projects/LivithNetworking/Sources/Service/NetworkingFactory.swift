//
//  NetworkingFactory.swift
//  LivithNetworking
//
//  Created by 김진웅 on 5/22/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

// MARK: - NetworkingFactory

public protocol NetworkingFactory: Sendable {
    var config: NetworkConfig { get }
    var onAuthenticationExpired: @Sendable () -> Void { get }
    func makeSongService() -> any SongService
    func makeSetlistService() -> any SetlistService
    func makeCommentService() -> any CommentService
    func makeSearchService() -> any SearchService
    func makePreferenceService() -> any PreferenceService
    func makeNotificationService() -> any NotificationService
}

// MARK: - NetworkingFactoryImpl

public struct NetworkingFactoryImpl: NetworkingFactory {
    public let config: NetworkConfig
    public let onAuthenticationExpired: @Sendable () -> Void

    private let networkClient: NetworkClient

    public init(
        config: NetworkConfig,
        onAuthenticationExpired: @Sendable @escaping () -> Void = {},
        tokenStore: any TokenStore = KeychainTokenStore()
    ) {
        self.config = config
        self.onAuthenticationExpired = onAuthenticationExpired

        // 1. TokenRefreshService를 위한 별도 NetworkClient
        //    AuthInterceptor 없음 - 순환 의존성 방지
        let refreshClient = NetworkClient(config: config, interceptor: nil)

        // 2. TokenRefreshService 생성 (순수 API 호출만 담당)
        let tokenRefreshService = TokenRefreshServiceImpl(networkClient: refreshClient)

        // 3. TokenManager 생성 (만료 이벤트 핸들러 연결)
        let tokenManager = TokenManagerImpl(
            tokenStore: tokenStore,
            tokenRefreshService: tokenRefreshService,
            onRefreshTokenExpired: onAuthenticationExpired
        )

        // 4. 도메인 서비스용 NetworkClient (AuthInterceptor 탑재)
        self.networkClient = NetworkClient(
            config: config,
            interceptor: AuthInterceptor(tokenManager: tokenManager),
            plugins: [DebugNetworkPlugin()]
        )
    }

    // MARK: - Service Factory

    public func makeSongService() -> any SongService {
        return SongServiceImpl(networkClient: networkClient)
    }

    public func makeSetlistService() -> any SetlistService {
        return SetlistServiceImpl(networkClient: networkClient)
    }

    public func makeCommentService() -> any CommentService {
        return CommentServiceImpl(networkClient: networkClient)
    }

    public func makeSearchService() -> any SearchService {
        return SearchServiceImpl(networkClient: networkClient)
    }

    public func makePreferenceService() -> any PreferenceService {
        return PreferenceServiceImpl(networkClient: networkClient)
    }

    public func makeNotificationService() -> any NotificationService {
        return NotificationServiceImpl(networkClient: networkClient)
    }
}
