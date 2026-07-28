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

    public init() {
        self.container = DIContainer.shared
    }
    
    public init(container: any DependencyContainer) {
        self.container = container
    }

    public var wrappedValue: T {
        get {
            return container.resolve(T.self)
        }
    }
}
