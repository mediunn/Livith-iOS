//
//  ConcertMatchingError.swift
//  Domain
//
//  Created by youz2me on 7/8/26.
//  Copyright © 2026 Livith. All rights reserved.
//

public enum ConcertMatchingError: Error {
    case noConnection
    case serverError
    case invalidResponse
    case matchFailed
    case unknown
    case cancelled
}
