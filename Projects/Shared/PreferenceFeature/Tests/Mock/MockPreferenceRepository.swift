//
//  MockPreferenceRepository.swift
//  PreferenceFeatureTests
//
//  Created by 김진웅 on 2/4/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

import Domain

final class MockPreferenceRepository: PreferenceRepository {
    var genreListStub: [PreferredGenre] = []
    var errorStub: PreferenceError?
    
    func fetchGenreList() async throws(PreferenceError) -> [PreferredGenre] {
        if let error = errorStub {
            throw error
        }
        return genreListStub
    }
    
    func searchArtistList(keyword: String?, size: Int?, cursor: String?) async throws(PreferenceError) -> ArtistSearchResult {
        fatalError("Not implemented")
    }
    
    func fetchUserPreferredGenreList() async throws(PreferenceError) -> [PreferredGenre] {
        return []
    }
    
    func fetchUserPreferredArtistList() async throws(PreferenceError) -> [PreferredArtist] {
        return []
    }
    
    func updateUserPreferredGenreList(genreIDs: [Int]) async throws(PreferenceError) -> [PreferredGenre] {
        return []
    }
    
    func updateUserPreferredArtistList(artistIDs: [Int]) async throws(PreferenceError) -> [PreferredArtist] {
        return []
    }
}
