//
//  KeychainStorage.swift
//  LivithNetworking
//
//  Created by 김진웅 on 5/11/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation
import Security

// MARK: - KeychainStorage

protocol KeychainStorage: Sendable {
    func save(_ data: Data, service: String, account: String) throws(KeychainStorageError)
    func load(service: String, account: String) throws(KeychainStorageError) -> Data
    func delete(service: String, account: String) throws(KeychainStorageError)
}

// MARK: - KeychainStorageError

enum KeychainStorageError: Error, Sendable {
    case itemNotFound
    case duplicateItem
    case unexpectedStatus(OSStatus)
}

// MARK: - KeychainStorageImpl

struct KeychainStorageImpl: KeychainStorage {
    func save(
        _ data: Data,
        service: String,
        account: String
    ) throws(KeychainStorageError) {
        let updateStatus = SecItemUpdate(
            keychainQuery(service: service, account: account) as CFDictionary,
            updateAttributes(data: data) as CFDictionary
        )

        switch updateStatus {
        case errSecSuccess:
            return
        case errSecItemNotFound:
            try add(data: data, service: service, account: account)
        default:
            throw .unexpectedStatus(updateStatus)
        }
    }

    func load(
        service: String,
        account: String
    ) throws(KeychainStorageError) -> Data {
        var query = keychainQuery(service: service, account: account)
        query[kSecReturnData as String] = kCFBooleanTrue
        query[kSecMatchLimit as String] = kSecMatchLimitOne

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        switch status {
        case errSecSuccess:
            guard let data = result as? Data else {
                throw .unexpectedStatus(status)
            }

            return data
        case errSecItemNotFound:
            throw .itemNotFound
        default:
            throw .unexpectedStatus(status)
        }
    }

    func delete(
        service: String,
        account: String
    ) throws(KeychainStorageError) {
        let status = SecItemDelete(keychainQuery(service: service, account: account) as CFDictionary)

        switch status {
        case errSecSuccess, errSecItemNotFound:
            return
        default:
            throw .unexpectedStatus(status)
        }
    }
}

private extension KeychainStorageImpl {
    func add(
        data: Data,
        service: String,
        account: String
    ) throws(KeychainStorageError) {
        var query = keychainQuery(service: service, account: account)
        query[kSecValueData as String] = data
        query[kSecAttrAccessible as String] = kSecAttrAccessibleWhenUnlockedThisDeviceOnly

        let status = SecItemAdd(query as CFDictionary, nil)

        switch status {
        case errSecSuccess:
            return
        case errSecDuplicateItem:
            let updateStatus = SecItemUpdate(
                keychainQuery(service: service, account: account) as CFDictionary,
                updateAttributes(data: data) as CFDictionary
            )

            guard updateStatus == errSecSuccess else {
                throw updateStatus == errSecDuplicateItem
                    ? .duplicateItem
                    : .unexpectedStatus(updateStatus)
            }
        default:
            throw .unexpectedStatus(status)
        }
    }

    func keychainQuery(
        service: String,
        account: String
    ) -> [String: Any] {
        [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]
    }

    func updateAttributes(data: Data) -> [String: Any] {
        [
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        ]
    }
}
