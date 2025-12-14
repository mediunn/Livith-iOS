//
//  TokenService.swift
//  LivithNetwork
//
//  Created by 김진웅 on 12/7/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import Foundation

public protocol TokenService: Sendable {
    func getAccessToken() async throws(TokenError) -> String
    func getRefreshToken() async throws(TokenError) -> String
    func saveToken(accessToken: String, refreshToken: String) async throws(TokenError)
    func refresh() async throws(TokenError)
    func removeToken() async throws(TokenError)
    func isRefreshTokenExpired() async -> Bool
}

public actor TokenServiceImpl: TokenService {
    private let storage: TokenStorage = .init()
    private let refresher: TokenRefresher = .init()
    
    private var refreshTask: Task<Void, Error>?
    
    public init() {}
    
    public func getAccessToken() async throws(TokenError) -> String {
        do {
            let token = try storage.fetch()
            return token.accessToken
        } catch TokenError.refreshTokenExpired {
            handleRefreshTokenExpired()
            throw .refreshTokenExpired
        }
    }
    
    public func getRefreshToken() async throws(TokenError) -> String {
        do {
            let token = try storage.fetch()
            return token.refreshToken
        } catch TokenError.refreshTokenExpired {
            handleRefreshTokenExpired()
            throw .refreshTokenExpired
        }
    }
    
    public func saveToken(accessToken: String, refreshToken: String) async throws(TokenError) {
        do {
            let token = Token(accessToken: accessToken, refreshToken: refreshToken, refreshTokenIssuedAt: .now)
            try storage.save(token)
        } catch {
            throw TokenError.saveFailed
        }
    }

    public func refresh() async throws(TokenError) {
        do {
            try await performRefresh()
        } catch TokenError.refreshTokenExpired {
            handleRefreshTokenExpired()
            throw .refreshTokenExpired
        } catch let error as TokenError {
            throw error
        } catch {
            throw TokenError.unknown
        }
    }
    
    public func removeToken() async throws(TokenError) {
        do {
            try storage.remove()
        } catch {
            throw TokenError.deleteFailed
        }
    }
    
    public func isRefreshTokenExpired() async -> Bool {
        (try? storage.fetch().refreshTokenIsExpired) ?? true
    }
}

// MARK: - Helpers

private extension TokenServiceImpl {
    func performRefresh() async throws {
        if let existingTask = refreshTask {
            try await existingTask.value
        }
        
        let task = Task<Void, Error> {
            let token = try self.storage.fetch()
            let response = try await self.refresher.refresh(with: token.refreshToken)
            
            let newToken = Token(
                accessToken: response.accessToken,
                refreshToken: response.refreshToken,
                refreshTokenIssuedAt: .now
            )
            
            try self.storage.save(newToken)
        }
        self.refreshTask = task
        
        defer { self.refreshTask = nil }
        
        try await task.value
    }
    
    func handleRefreshTokenExpired() {
        try? storage.remove()
        notifyReloginRequired()
    }
    
    func notifyReloginRequired() {
        Task { @MainActor in
            NotificationCenter.default.post(name: .reloginRequired, object: nil)
        }
    }
}

// MARK: - Notification.Name Extension

public extension Notification.Name {
    static let reloginRequired = Notification.Name("reloginRequired")
}
