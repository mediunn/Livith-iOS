//
//  SearchError.swift
//  Domain
//
//  Created by 김진웅 on 1/21/26.
//  Copyright © 2026 Livith. All rights reserved.
//

public enum SearchError: Error {
    case noSearchResult
    case noConnection
    case serverError
    case invalidResponse
    case unknown
    case invalidGenre
    case invalidStatus
    case invalidSort
    case invalidSize
    case invalidCursor
    case invalidID
    case missingKeyword
    case cancelled
}
