//
//  LocalKeyValueStorage.swift
//  Persistence
//
//  Created by 김진웅 on 12/11/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import Foundation

public protocol LocalKeyValueStorage {
    func save<T: Encodable>(_ value: T, for key: String) throws(StorageError)
    func fetch<T: Decodable>(for key: String) throws(StorageError) -> T
    func remove(for key: String)
}

public struct UserDefaultsStorage: LocalKeyValueStorage {
    let defaults: UserDefaults
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder

    public init(
        defaults: UserDefaults = .standard,
        encoder: JSONEncoder = .init(),
        decoder: JSONDecoder = .init()
    ) {
        self.defaults = defaults
        self.encoder = encoder
        self.decoder = decoder
    }

    public func save<T: Encodable>(_ value: T, for key: String) throws(StorageError) {
        do {
            let data = try encoder.encode(value)
            defaults.set(data, forKey: key)
        } catch {
            throw StorageError.encodingFailed
        }
    }

    public func fetch<T: Decodable>(for key: String) throws(StorageError) -> T {
        guard let data = defaults.data(forKey: key) else {
            throw StorageError.dataNotFound
        }
        
        do {
            let value = try decoder.decode(T.self, from: data)
            return value
        } catch {
            throw StorageError.decodingFailed
        }
    }

    public func remove(for key: String) {
        defaults.removeObject(forKey: key)
    }
}
