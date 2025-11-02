//
//  Injected.swift
//  core
//
//  Created by 김진웅 on 10/12/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import Foundation

@propertyWrapper
public struct Injected<T> {
    private let container: any DependencyContainer
    private let lock = NSLock()

    private var _value: T?

    public init() {
        self.container = DIContainer.shared
        self._value = nil
    }
    
    public init(container: any DependencyContainer) {
        self.container = container
        self._value = nil
    }

    public var wrappedValue: T {
        mutating get {
            lock.lock()
            defer { lock.unlock() }
            
            if let cachedValue = _value {
                return cachedValue
            }
            
            let resolved = container.resolve(T.self)
            _value = resolved
            return resolved
        }
    }
}
