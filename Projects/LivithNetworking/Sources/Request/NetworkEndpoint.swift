//
//  NetworkEndpoint.swift
//  LivithNetworking
//
//  Created by 김진웅 on 5/8/26.
//  Copyright © 2026 Livith. All rights reserved.
//

public protocol NetworkEndpoint {
    var path: String { get }
    var method: HTTPMethod { get }
    var task: RequestTask { get }
    var headers: [String: String] { get }
    var requiresAuthentication: Bool { get }
}

public extension NetworkEndpoint {
    var task: RequestTask { .plain }
    var headers: [String: String] { [:] }
    var requiresAuthentication: Bool { true }
}
