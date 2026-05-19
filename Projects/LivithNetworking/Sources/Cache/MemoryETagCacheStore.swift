//
//  MemoryETagCacheStore.swift
//  LivithNetworking
//
//  Created by 김진웅 on 5/13/26.
//  Copyright © 2026 Livith. All rights reserved.
//

actor MemoryETagCacheStore: ETagCacheStore {
    private var storage: [String: ETagCacheEntry] = [:]

    func value(for key: String) -> ETagCacheEntry? {
        storage[key]
    }

    func save(
        _ entry: ETagCacheEntry,
        for key: String
    ) {
        storage[key] = entry
    }

    func remove(for key: String) {
        storage[key] = nil
    }

    func removeAll() {
        storage.removeAll()
    }
}
