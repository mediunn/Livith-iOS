//
//  TokenService.swift
//  LivithNetwork
//
//  Created by 김진웅 on 12/7/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import Foundation

public protocol TokenService {
    func getAccessToken() async throws(TokenError) -> String
    func saveTokens(accessToken: String, refreshToken: String) throws(TokenError)
    func removeTokens() throws(TokenError)
    func refreshTokens() async throws(TokenError) -> String
}

public final class TokenServiceImpl: TokenService {
    private let storage: TokenStorage = .init()
    private let refresher: TokenRefresher = .init()
    
    public init() {}
    
    public func getAccessToken() async throws(TokenError) -> String {
        do {
            let token = try storage.fetch()
            return token.accessToken
        } catch TokenError.expired {
            postReloginNotification()
            throw .expired
        }
    }
    
    public func saveTokens(accessToken: String, refreshToken: String) throws(TokenError) {
        let token = Token(
            accessToken: accessToken,
            refreshToken: refreshToken,
            refreshTokenIssuedAt: Date()
        )
        try storage.save(token)
    }
    
    public func removeTokens() throws(TokenError) {
        do {
            try storage.delete()
        } catch TokenError.expired {
            NotificationCenter.default.post(name: .reloginRequired, object: nil)
            throw TokenError.expired
        }
    }
    
    public func refreshTokens() async throws(TokenError) -> String {
        do {
            let token = try storage.fetch()
            let newTokens = try await refresher.refresh(with: token.refreshToken)
            let newToken = Token(
                accessToken: newTokens.accessToken,
                refreshToken: newTokens.refreshToken,
                refreshTokenIssuedAt: Date()
            )
            try storage.save(newToken)
            return newToken.accessToken
        } catch TokenError.expired {
            NotificationCenter.default.post(name: .reloginRequired, object: nil)
            throw TokenError.expired
        }
    }
}

// MARK: - Helpers

private extension TokenServiceImpl {
    func postReloginNotification() {
        NotificationCenter.default.post(name: .reloginRequired, object: nil)
    }
}

// MARK: - Notification.Name Extension

fileprivate extension Notification.Name {
    static let reloginRequired = Notification.Name("reloginRequired")
}
