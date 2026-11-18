//
//  ConcertError.swift
//  Domain
//
//  Created by 김진웅 on 1/21/26.
//  Copyright © 2026 Livith. All rights reserved.
//

public enum ConcertError: Error {
    case noConnection
    case serverError
    case invalidResponse
    case invalidRequest
    case unknown
    case invalidID
    case invalidSize
    case concertNotFound
    case artistNotFound
    case cancelled
}
