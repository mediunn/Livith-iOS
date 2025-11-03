//
//  DependencyContainer.swift
//  core
//
//  Created by 김진웅 on 10/12/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import Foundation

// MARK: - Dependency Container Protocols

public protocol DependencyRegistable {
    func register<T>(_ dependency: T, for type: T.Type)
    func register<T>(_ factory: @escaping () -> T, for type: T.Type)
}

public protocol DependencyResolvable {
    func resolve<T>(_ type: T.Type) -> T
}

public protocol AssemblerRegistable {
    func register(assemblers: [any DependencyAssembler])
}

public typealias DependencyContainer = DependencyRegistable & DependencyResolvable

// MARK: - Dependency Container Implementation

public final class DIContainer: DependencyContainer, AssemblerRegistable {
    public static let shared = DIContainer()

    private enum Entry {
        case instance(Any)
        case factory(() -> Any)
    }
    
    private var dependencies: [ObjectIdentifier: Entry] = [:]

    private let queue = DispatchQueue(label: "com.livith.DIContainer.queue", qos: .userInitiated)

    private init() {}

    public func register<T>(_ dependency: T, for type: T.Type) {
        queue.sync {
            let key = ObjectIdentifier(type)
            dependencies[key] = .instance(dependency)
        }
    }
    
    public func register<T>(_ factory: @escaping () -> T, for type: T.Type) {
        queue.sync {
            let key = ObjectIdentifier(type)
            let anyFactory: () -> Any = { factory() }
            dependencies[key] = .factory(anyFactory)
        }
    }
    
    public func resolve<T>(_ type: T.Type) -> T {
        let entry: Entry = queue.sync {
            let key = ObjectIdentifier(type)
            guard let entry = dependencies[key] else {
                fatalError("\(type) is not registered")
            }
            return entry
        }

        switch entry {
        case .instance(let service):
            guard let typedService = service as? T else {
                fatalError("Registered dependency for \(type) has mismatched type")
            }
            return typedService

        case .factory(let factory):
            let instance = factory()
            guard let typedInstance = instance as? T else {
                fatalError("Factory for \(type) returned mismatched type")
            }
            return typedInstance
        }
    }
    
    public func register(assemblers: [any DependencyAssembler]) {
        assemblers.forEach { $0.assemble(to: self) }
    }
}
