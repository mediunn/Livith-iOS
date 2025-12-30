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
        print("[TokenStorage] 🔵 save() 시작")
        try? remove()
        
        do {
            try add(key: .accessToken, value: token.accessToken)
            try add(key: .refreshToken, value: token.refreshToken)
            
            let issuedAtString = String(token.refreshTokenIssuedAt.timeIntervalSince1970)
            try add(key: .issuedAt, value: issuedAtString)
            print("[TokenStorage] ✅ save() 완료")
        } catch {
            print("[TokenStorage] ❌ save() 실패: \(error)")
            throw TokenError.storage(.saveFailed)
        }
    }
    
    func fetch() throws(TokenError) -> Token {
        print("[TokenStorage] 🔵 fetch() 시작")
        let accessToken = try fetch(key: .accessToken)
        let refreshToken = try fetch(key: .refreshToken)
        let issuedAtString = try fetch(key: .issuedAt)
        
        guard let timeInterval = TimeInterval(issuedAtString) else {
            print("[TokenStorage] ❌ fetch() 실패: 유효하지 않은 issuedAt 형식")
            throw TokenError.storage(.noData)
        }
        let issuedAt = Date(timeIntervalSince1970: timeInterval)

        let token = Token(accessToken: accessToken, refreshToken: refreshToken, refreshTokenIssuedAt: issuedAt)

        if token.refreshTokenIsExpired {
            print("[TokenStorage] ❌ fetch() 실패: refreshToken 만료됨")
            throw .storage(.refreshTokenExpired)
        }
        
        print("[TokenStorage] ✅ fetch() 완료")
        return token
    }
    
    func remove() throws(TokenError) {
        print("[TokenStorage] 🔵 remove() 시작")
        let keysToDelete: [Keys] = [.accessToken, .refreshToken, .issuedAt]
        
        for key in keysToDelete {
            let status = delete(key: key)
            if status != errSecSuccess && status != errSecItemNotFound {
                print("[TokenStorage] ❌ remove() 실패: \(key.description) 삭제 중 에러")
                throw TokenError.storage(.deleteFailed)
            }
        }
        print("[TokenStorage] ✅ remove() 완료")
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
            throw TokenError.storage(.saveFailed)
        }
        
        var query = keychainQuery(for: key)
        query[kSecValueData as String] = valueData
        query[kSecAttrAccessible as String] = kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        
        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else {
            throw TokenError.storage(.saveFailed)
        }
    }
    
    func fetch(key: Keys) throws(TokenError) -> String {
        var query = keychainQuery(for: key)
        query[kSecReturnData as String] = kCFBooleanTrue
        query[kSecMatchLimit as String] = kSecMatchLimitOne
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status != errSecItemNotFound else {
            throw TokenError.storage(.noData)
        }
        
        guard status == errSecSuccess else {
            throw TokenError.unknown
        }
        
        guard let data = result as? Data,
              let value = String(data: data, encoding: .utf8)
        else {
            throw TokenError.storage(.noData)
        }

        return value
    }
    
    @discardableResult
    func delete(key: Keys) -> OSStatus {
        let query = keychainQuery(for: key)
        let status = SecItemDelete(query as CFDictionary)
        return status
    }
    
    func keychainQuery(for key: Keys) -> [String: Any] {
        return [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceID,
            kSecAttrAccount as String: key.description
        ]
    }
}
