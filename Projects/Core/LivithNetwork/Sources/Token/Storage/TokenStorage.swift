//
//  TokenStorage.swift
//  LivithNetwork
//
//  Created by 김진웅 on 12/7/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import Foundation
import Security

struct TokenStorage {
    private let serviceID: String
    
    init(serviceID: String = Bundle.main.bundleIdentifier ?? "com.youz2me.livith.network") {
        self.serviceID = serviceID
    }
    
    func save(_ token: Token) throws(TokenError) {
        try? delete()
        
        do {
            try add(key: .accessToken, value: token.accessToken)
            try add(key: .refreshToken, value: token.refreshToken)
            
            let issuedAtString = String(token.refreshTokenIssuedAt.timeIntervalSince1970)
            try add(key: .issuedAt, value: issuedAtString)
        } catch {
            throw TokenError.saveFailed
        }
    }
    
    func fetch() throws(TokenError) -> Token {
        let accessToken = try fetch(key: .accessToken)
        let refreshToken = try fetch(key: .refreshToken)
        let issuedAtString = try fetch(key: .issuedAt)
        
        guard let timeInterval = TimeInterval(issuedAtString) else {
            throw TokenError.noData
        }
        let issuedAt = Date(timeIntervalSince1970: timeInterval)

        let token = Token(accessToken: accessToken, refreshToken: refreshToken, refreshTokenIssuedAt: issuedAt)

        if token.isExpired {
            throw .expired
        }
        
        return token
    }
    
    func delete() throws(TokenError) {
        let keysToDelete: [Keys] = [.accessToken, .refreshToken, .issuedAt]
        
        for key in keysToDelete {
            let status = delete(key: key)
            if status != errSecSuccess && status != errSecItemNotFound {
                throw TokenError.deleteFailed
            }
        }
    }
}

// MARK: - Helpers

private extension TokenStorage {
    enum Keys: CustomStringConvertible {
        case accessToken
        case refreshToken
        case issuedAt
        
        var description: String {
            switch self {
            case .accessToken: "accessToken"
            case .refreshToken: "refreshToken"
            case .issuedAt: "issuedAt"
            }
        }
    }
    
    func add(key: Keys, value: String) throws(TokenError) {
        guard let valueData = value.data(using: .utf8) else {
            throw TokenError.saveFailed
        }
        
        var query = keychainQuery(for: key)
        query[kSecValueData as String] = valueData
        query[kSecAttrAccessible as String] = kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        
        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else {
            throw TokenError.saveFailed
        }
    }
    
    func fetch(key: Keys) throws(TokenError) -> String {
        var query = keychainQuery(for: key)
        query[kSecReturnData as String] = true
        query[kSecMatchLimit as String] = kSecMatchLimitOne
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status != errSecItemNotFound else {
            throw TokenError.notFound
        }
        
        guard status == errSecSuccess else {
            throw TokenError.unknown
        }
        
        guard let data = result as? Data,
              let value = String(data: data, encoding: .utf8)
        else {
            throw TokenError.noData
        }
        
        return value
    }
    
    @discardableResult
    func delete(key: Keys) -> OSStatus {
        let query = keychainQuery(for: key)
        return SecItemDelete(query as CFDictionary)
    }
    
    func keychainQuery(for key: Keys) -> [String: Any] {
        return [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceID,
            kSecAttrAccount as String: key.description
        ]
    }
}
