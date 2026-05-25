//
//  NetworkEndpoint.swift
//  LivithNetworking
//
//  Created by 김진웅 on 5/8/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

// MARK: - AuthenticationPolicy

public enum AuthenticationPolicy: Sendable {
    case required
    case none
}

// MARK: - CachePolicy

public enum CachePolicy: Sendable {
    case disabled
    case enabled
}

// MARK: - NetworkEndpoint

public struct NetworkEndpoint {
    public let path: String
    public let method: HTTPMethod
    public let task: RequestTask
    public let headers: [String: String]
    public let authentication: AuthenticationPolicy
    public let cache: CachePolicy

    public init(
        path: String,
        method: HTTPMethod,
        task: RequestTask = .plain,
        headers: [String: String] = [:],
        authentication: AuthenticationPolicy = .required,
        cache: CachePolicy = .disabled
    ) {
        self.path = path
        self.method = method
        self.task = task
        self.headers = headers
        self.authentication = authentication
        self.cache = cache
    }
}
