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
    func refresh() async throws(TokenError) -> String
    func removeTokens() async throws(TokenError)
    func isRefreshTokenExpired() async -> Bool
}

public actor TokenServiceImpl: TokenService {
    private let storage: TokenStorage = .init()
    private let refresher: TokenRefresher = .init()
    
    private var refreshTask: Task<String, Error>?
    
    public init() {}
    
    public func getAccessToken() async throws(TokenError) -> String {
        do {
            let token = try storage.fetch()
            return token.accessToken
        } catch TokenError.refreshTokenExpired {
            notifyReloginRequired()
            throw .refreshTokenExpired
        }
    }
    
    public func getRefreshToken() async throws(TokenError) -> String {
        do {
            let token = try storage.fetch()
            return token.refreshToken
        } catch TokenError.refreshTokenExpired {
            notifyReloginRequired()
            throw .refreshTokenExpired
        }
    }
    
    public func refresh() async throws(TokenError) -> String {
        do {
            return try await performRefresh()
        } catch TokenError.refreshTokenExpired {
            notifyReloginRequired()
            throw .refreshTokenExpired
        } catch let error as TokenError {
            throw error
        } catch {
            throw TokenError.unknown
        }
    }
    
    public func removeTokens() async throws(TokenError) {
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
    func performRefresh() async throws -> String {
        if let existingTask = refreshTask {
            return try await existingTask.value
        }
        
        let task = Task<String, Error> {
            let token = try self.storage.fetch()
            let response = try await self.refresher.refresh(with: token.refreshToken)
            
            let newToken = Token(
                accessToken: response.accessToken,
                refreshToken: response.refreshToken,
                refreshTokenIssuedAt: .now
            )
            
            try self.storage.save(newToken)
            return newToken.accessToken
        }
        self.refreshTask = task
        
        defer { self.refreshTask = nil }
        
        return try await task.value
    }
    
    func notifyReloginRequired() {
        Task { @MainActor in
            NotificationCenter.default.post(name: .reloginRequired, object: nil)
        }
    }
}

// MARK: - Notification.Name Extension

fileprivate extension Notification.Name {
    static let reloginRequired = Notification.Name("reloginRequired")
}
