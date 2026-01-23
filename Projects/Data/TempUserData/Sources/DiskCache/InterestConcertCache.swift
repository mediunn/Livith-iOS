//
//  InterestConcertCache.swift
//  Data
//
//  Created by 김진웅 on 1/22/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

import Domain
import Persistence

actor InterestConcertCache {
    private static let cacheExpirationInterval: TimeInterval = 5 * 60
    private static let imageKey: String = "interestConcertPoster"

    private let userdefaultsStorage: UserDefaultsStorage
    private let widgetImageStorage: WidgetImageStorage

    private var timestamp: Date? = nil
    private var cachedConcert: Concert? = nil

    init(userdefaultsStorage: UserDefaultsStorage, widgetImageStorage: WidgetImageStorage) {
        self.userdefaultsStorage = userdefaultsStorage
        self.widgetImageStorage = widgetImageStorage

        self.cachedConcert = try? userdefaultsStorage.fetch(for: .interestConcert)
    }

    func fetchInterestConcertIfValid() -> Concert? {
        guard let timestamp = timestamp,
              Date().timeIntervalSince(timestamp) < Self.cacheExpirationInterval
        else {
            return nil
        }
        return cachedConcert
    }

    func fetchInterestConcert() -> Concert? {
        return cachedConcert
    }

    func isCacheExpired() -> Bool {
        guard let timestamp = timestamp else {
            return true
        }
        return Date().timeIntervalSince(timestamp) >= Self.cacheExpirationInterval
    }

    func saveInterestConcert(_ concert: Concert) async {
        cachedConcert = concert
        timestamp = Date()
        try? userdefaultsStorage.save(concert, for: .interestConcert)
        await widgetImageStorage.download(from: concert.posterURL.absoluteString, forKey: Self.imageKey)
    }

    func deleteInterestConcert() {
        cachedConcert = nil
        timestamp = nil
        userdefaultsStorage.remove(for: .interestConcert)
        widgetImageStorage.remove(forKey: Self.imageKey)
    }
}
