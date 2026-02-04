//
//  PreferenceRepository.swift
//  Domain
//
//  Created by 김진웅 on 2/4/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

public protocol PreferenceRepository {
    func fetchGenreList() async throws(PreferenceError) -> [PreferredGenre]
    func searchArtistList(
        keyword: String?,
        size: Int?,
        cursor: String?
    ) async throws(PreferenceError) -> ArtistSearchResult
    func fetchUserPreferredGenreList() async throws(PreferenceError) -> [PreferredGenre]
    func fetchUserPreferredArtistList() async throws(PreferenceError) -> [PreferredArtist]
    @discardableResult
    func updateUserPreferredGenreList(genreIDs: [Int]) async throws(PreferenceError) -> [PreferredGenre]
    @discardableResult
    func updateUserPreferredArtistList(artistIDs: [Int]) async throws(PreferenceError) -> [PreferredArtist]
}
