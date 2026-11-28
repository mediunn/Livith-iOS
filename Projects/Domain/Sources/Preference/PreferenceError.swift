//
//  PreferenceError.swift
//  Domain
//
//  Created by 김진웅 on 2/4/26.
//  Copyright © 2026 Livith. All rights reserved.
//

public enum PreferenceError: Error {
    // MARK: - Common
    case noConnection
    case serverError
    case invalidResponse
    case unknown
    case cancelled

    // MARK: - User
    case userNotFound
    case withdrawn

    // MARK: - Cursor/Pagination
    case invalidCursor
    case invalidSize

    // MARK: - Genre
    case genreNotFound
    case minGenreRequired
    case maxGenreExceeded
    case invalidGenreID

    // MARK: - Artist
    case artistNotFound
    case maxArtistExceeded
    case invalidArtistID
}
