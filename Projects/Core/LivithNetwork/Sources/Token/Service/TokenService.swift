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
    func refreshTokens() async throws(TokenError) -> String
    func removeTokens() async throws(TokenError)
    var isRefreshTokenExpired: Bool { get }
}

public final class TokenServiceImpl: TokenService {
    private let storage: TokenStorage = .init()
    private let refresher: TokenRefresher = .init()
    
    public init() {}
    
    public func getAccessToken() async throws(TokenError) -> String {
        do {
            let token = try storage.fetch()
            return token.accessToken
        } catch TokenError.refreshTokenExpired {
            postReloginNotification()
            throw .refreshTokenExpired
        }
    }

    public func refreshTokens() async throws(TokenError) -> String {
        do {
            let token = try storage.fetch()
            let response = try await refresher.refresh(with: token.refreshToken)
            let newToken = Token(
                accessToken: response.accessToken,
                refreshToken: response.refreshToken,
                refreshTokenIssuedAt: .now
            )
            try storage.save(newToken)
            return newToken.accessToken
        } catch TokenError.refreshTokenExpired {
            postReloginNotification()
            throw .refreshTokenExpired
        }
    }

    public func removeTokens() async throws(TokenError) {
        do {
            try storage.delete()
        } catch {
            throw TokenError.deleteFailed
        }
    }

    public var isRefreshTokenExpired: Bool {
        (try? storage.fetch().refreshTokenIsExpired) ?? true
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
