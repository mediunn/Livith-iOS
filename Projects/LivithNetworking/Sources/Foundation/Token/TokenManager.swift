//
//  TokenManager.swift
//  LivithNetworking
//
//  Created by 김진웅 on 5/13/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

// MARK: - TokenManager

protocol TokenManager: Sendable {
    func accessToken() async throws(NetworkError) -> String
    func refresh() async throws(NetworkError)
}

// MARK: - TokenManagerImpl

actor TokenManagerImpl: TokenManager {
    private let tokenStore: any TokenStore
    private let tokenRefreshService: any TokenRefreshService
    private let onRefreshTokenExpired: (@Sendable () -> Void)?
    private var refreshTask: Task<Void, any Error>?

    init(
        tokenStore: any TokenStore,
        tokenRefreshService: any TokenRefreshService,
        onRefreshTokenExpired: (@Sendable () -> Void)? = nil
    ) {
        self.tokenStore = tokenStore
        self.tokenRefreshService = tokenRefreshService
        self.onRefreshTokenExpired = onRefreshTokenExpired
    }

    func accessToken() async throws(NetworkError) -> String {
        do {
            return try await tokenStore.fetch().accessToken
        } catch let error {
            throw mapFetchError(error)
        }
    }

    func refresh() async throws(NetworkError) {
        if let refreshTask {
            return try await value(from: refreshTask)
        }

        let task = Task {
            try await self.performRefresh()
        }
        refreshTask = task

        defer { refreshTask = nil }

        try await value(from: task)
    }
}

private extension TokenManagerImpl {
    func performRefresh() async throws(NetworkError) {
        let storedToken: Token
        do {
            storedToken = try await tokenStore.fetch()
        } catch {
            throw mapFetchError(error)
        }

        let refreshedToken: Token
        do {
            refreshedToken = try await tokenRefreshService.refresh(
                with: storedToken.refreshToken
            )
        } catch {
            if case .unauthorized = error {
                onRefreshTokenExpired?()
                try? await tokenStore.remove()
            }
            throw error
        }

        do {
            try await tokenStore.save(refreshedToken)
        } catch {
            throw mapSaveError(error)
        }
    }

    func value(from task: Task<Void, any Error>) async throws(NetworkError) {
        do {
            try await task.value
        } catch let error as NetworkError {
            throw error
        } catch {
            throw .unknown(error)
        }
    }

    func mapFetchError(_ error: TokenError) -> NetworkError {
        .unauthorized(message: nil)
    }

    func mapSaveError(_ error: TokenError) -> NetworkError {
        .unknown(error)
    }
}
