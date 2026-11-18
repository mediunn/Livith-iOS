//
//  SetlistError.swift
//  Domain
//
//  Created by 김진웅 on 1/21/26.
//  Copyright © 2026 Livith. All rights reserved.
//

public enum SetlistError: Error {
    case noConnection
    case serverError
    case invalidResponse
    case notFound
    case unknown
    case invalidID
    case concertNotFound
    case combinationNotFound
    case cancelled
}
