//
//  CalendarError.swift
//  Domain
//
//  Created by 김진웅 on 7/23/26.
//  Copyright © 2026 Livith. All rights reserved.
//

public enum CalendarError: Error {
    case noConnection
    case serverError
    case invalidResponse
    case invalidRequest
    case unauthorized
    case cancelled
    case unknown
}
