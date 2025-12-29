//
//  TestTokenHelper.swift
//  ConcertDataTests
//
//  Created by Youjin Lee on 12/25/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import Foundation
import Security

enum TestTokenHelper {
    // MARK: - 테스트용 토큰 (실제 토큰으로 교체 필요)
    static let accessToken = "YOUR_ACCESS_TOKEN_HERE"
    static let refreshToken = "YOUR_REFRESH_TOKEN_HERE"

    private static let serviceID = "com.youz2me.livith.network"

    static func setupToken() {
        removeToken()

        saveToKeychain(key: "accessToken", value: accessToken)
        saveToKeychain(key: "refreshToken", value: refreshToken)
        saveToKeychain(key: "issuedAt", value: String(Date().timeIntervalSince1970))
    }

    static func removeToken() {
        deleteFromKeychain(key: "accessToken")
        deleteFromKeychain(key: "refreshToken")
        deleteFromKeychain(key: "issuedAt")
    }

    private static func saveToKeychain(key: String, value: String) {
        guard let valueData = value.data(using: .utf8) else { return }

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceID,
            kSecAttrAccount as String: key,
            kSecValueData as String: valueData,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        ]

        SecItemAdd(query as CFDictionary, nil)
    }

    private static func deleteFromKeychain(key: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceID,
            kSecAttrAccount as String: key
        ]

        SecItemDelete(query as CFDictionary)
    }
}
