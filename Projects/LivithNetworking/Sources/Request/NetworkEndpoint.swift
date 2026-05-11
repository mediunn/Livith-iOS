//
//  NetworkEndpoint.swift
//  LivithNetworking
//
//  Created by 김진웅 on 5/8/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

public struct NetworkEndpoint {
    public let path: String
    public let method: HTTPMethod
    public let task: RequestTask
    public let headers: [String: String]
    public let requiresAuthentication: Bool

    public init(
        path: String,
        method: HTTPMethod,
        task: RequestTask = .plain,
        headers: [String: String] = [:],
        requiresAuthentication: Bool = true
    ) {
        self.path = path
        self.method = method
        self.task = task
        self.headers = headers
        self.requiresAuthentication = requiresAuthentication
    }
}
