//
//  RequestInterceptor.swift
//  LivithNetworking
//
//  Created by 김진웅 on 5/11/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

public protocol RequestInterceptor: Sendable {
    func adapt(
        _ request: URLRequest
    ) async throws(NetworkError) -> URLRequest

    func retry(
        _ request: URLRequest,
        dueTo error: NetworkError,
        response: HTTPURLResponse?,
        retryCount: Int
    ) async -> RetryResult
}

public enum RetryResult: Sendable {
    case retry
    case doNotRetry
}
