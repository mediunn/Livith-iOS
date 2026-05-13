//
//  TokenManager.swift
//  LivithNetworking
//
//  Created by 김진웅 on 5/13/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

// MARK: - TokenManager

public protocol TokenManager: Sendable {
    func accessToken() async throws(NetworkError) -> String
    func refresh() async throws(NetworkError)
}

// MARK: - TokenManagerImpl

public actor TokenManagerImpl: TokenManager {
    private let tokenStore: any TokenStore
    private let tokenRefreshService: any TokenRefreshService
    private var refreshTask: Task<Void, any Error>?

    public init(
        tokenStore: any TokenStore,
        tokenRefreshService: any TokenRefreshService
    ) {
        self.tokenStore = tokenStore
        self.tokenRefreshService = tokenRefreshService
    }

    public func accessToken() async throws(NetworkError) -> String {
        do {
            return try await tokenStore.fetch().accessToken
        } catch let error as TokenError {
            throw mapFetchError(error)
        } catch {
            throw .unknown(error)
        }
    }

    public func refresh() async throws(NetworkError) {
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
        } catch let error as TokenError {
            throw mapFetchError(error)
        } catch {
            throw .unknown(error)
        }

        let refreshedToken = try await tokenRefreshService.refresh(
            with: storedToken.refreshToken
        )

        do {
            try await tokenStore.save(refreshedToken)
        } catch let error as TokenError {
            throw mapSaveError(error)
        } catch {
            throw .unknown(error)
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
