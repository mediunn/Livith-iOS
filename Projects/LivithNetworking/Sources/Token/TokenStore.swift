//
//  TokenStore.swift
//  LivithNetworking
//
//  Created by 김진웅 on 5/11/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

// MARK: - TokenStore

public protocol TokenStore: Sendable {
    func save(_ token: Token) async throws(TokenError)
    func fetch() async throws(TokenError) -> Token
    func remove() async throws(TokenError)
    func isRefreshTokenExpired() async -> Bool
}

// MARK: - KeychainTokenStore

public actor KeychainTokenStore: TokenStore {
    public static let defaultService = "com.livith.livith-networking.token-store"
    public static let defaultAccount = "token"

    private let service: String
    private let account: String
    private let expirationPolicy: TokenExpirationPolicy
    private let keychainStorage: any KeychainStorage
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder

    public init(
        service: String = KeychainTokenStore.defaultService,
        account: String = KeychainTokenStore.defaultAccount,
        expirationPolicy: TokenExpirationPolicy = .default
    ) {
        self.init(
            service: service,
            account: account,
            expirationPolicy: expirationPolicy,
            keychainStorage: KeychainStorageImpl()
        )
    }

    init(
        service: String,
        account: String,
        expirationPolicy: TokenExpirationPolicy = .default,
        keychainStorage: any KeychainStorage
    ) {
        self.service = service
        self.account = account
        self.expirationPolicy = expirationPolicy
        self.keychainStorage = keychainStorage
        self.encoder = Self.makeEncoder()
        self.decoder = Self.makeDecoder()
    }

    public func save(_ token: Token) async throws(TokenError) {
        let data = try encode(token)

        do {
            try keychainStorage.save(data, service: service, account: account)
        } catch {
            throw .saveFailed
        }
    }

    public func fetch() async throws(TokenError) -> Token {
        let data: Data
        do {
            data = try keychainStorage.load(service: service, account: account)
        } catch .itemNotFound {
            throw .noToken
        } catch {
            throw .loadFailed
        }

        return try decode(data)
    }

    public func remove() async throws(TokenError) {
        do {
            try keychainStorage.delete(service: service, account: account)
        } catch .itemNotFound {
            return
        } catch {
            throw .deleteFailed
        }
    }

    public func isRefreshTokenExpired() async -> Bool {
        guard let token = try? await fetch() else { return true }

        return expirationPolicy.isRefreshTokenExpired(
            issuedAt: token.refreshTokenIssuedAt
        )
    }
}

private extension KeychainTokenStore {
    static func makeEncoder() -> JSONEncoder {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .secondsSince1970

        return encoder
    }

    static func makeDecoder() -> JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .secondsSince1970

        return decoder
    }

    func encode(_ token: Token) throws(TokenError) -> Data {
        do {
            return try encoder.encode(token)
        } catch {
            throw .encodingFailed
        }
    }

    func decode(_ data: Data) throws(TokenError) -> Token {
        do {
            return try decoder.decode(Token.self, from: data)
        } catch {
            throw .decodingFailed
        }
    }
}
