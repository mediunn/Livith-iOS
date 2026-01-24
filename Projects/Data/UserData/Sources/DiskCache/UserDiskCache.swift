//
//  UserDiskCache.swift
//  Data
//
//  Created by 김진웅 on 1/22/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

import Domain
import Persistence

actor UserDiskCache {
    private static let cacheExpirationInterval: TimeInterval = 5 * 60

    private let userdefaultsStorage: UserDefaultsStorage

    private var timestamp: Date? = nil
    private var cachedUser: User? = nil

    init(userdefaultsStorage: UserDefaultsStorage) {
        self.userdefaultsStorage = userdefaultsStorage
        self.cachedUser = try? userdefaultsStorage.fetch(for: .currentUser)
    }

    func fetchUserIfValid() -> User? {
        guard let timestamp = timestamp,
              Date().timeIntervalSince(timestamp) < Self.cacheExpirationInterval
        else {
            return nil
        }
        return cachedUser
    }

    func fetchUser() -> User? {
        return cachedUser
    }

    func isCacheExpired() -> Bool {
        guard let timestamp = timestamp else {
            return true
        }
        return Date().timeIntervalSince(timestamp) >= Self.cacheExpirationInterval
    }

    func saveUser(_ user: User) {
        cachedUser = user
        timestamp = Date()
        try? userdefaultsStorage.save(user, for: .currentUser)
    }

    func updateUser(_ transform: (inout User) -> Void) {
        guard var user = cachedUser else { return }
        transform(&user)
        saveUser(user)
    }

    func deleteUser() {
        cachedUser = nil
        timestamp = nil
        userdefaultsStorage.remove(for: .currentUser)
    }
}
