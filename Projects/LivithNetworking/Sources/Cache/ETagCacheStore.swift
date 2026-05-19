//
//  ETagCacheStore.swift
//  LivithNetworking
//
//  Created by 김진웅 on 5/13/26.
//  Copyright © 2026 Livith. All rights reserved.
//

protocol ETagCacheStore: AnyObject, Sendable {
    func value(for key: String) async -> ETagCacheEntry?
    func save(_ entry: ETagCacheEntry, for key: String) async
    func remove(for key: String) async
    func removeAll() async
}
