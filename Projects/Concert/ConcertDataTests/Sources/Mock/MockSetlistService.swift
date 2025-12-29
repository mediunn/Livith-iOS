//
//  MockSetlistService.swift
//  ConcertDataTests
//
//  Created by Youjin Lee on 12/25/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import Foundation

@testable import LivithNetwork

final class MockSetlistService: SetlistServiceProtocol {
    var mockResponse: Any?
    var mockError: Error?

    func request<T: Decodable>(_ endPoint: SetlistEndpoint) async throws(NetworkError) -> T {
        if let error = mockError as? NetworkError {
            throw error
        }
        if let error = mockError {
            throw NetworkError.unknown(error)
        }
        guard let response = mockResponse as? T else {
            throw NetworkError.invalidResponse
        }
        return response
    }
}
