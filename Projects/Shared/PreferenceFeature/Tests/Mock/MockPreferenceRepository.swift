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
    var artistSearchResultStub: ArtistSearchResult = ArtistSearchResult(artists: [], cursor: nil, totalCount: 0)
    var errorStub: PreferenceError?
    
    var fetchGenreListCallCount: Int = 0
    var searchArtistListCallCount: Int = 0
    
    func fetchGenreList() async throws(PreferenceError) -> [PreferredGenre] {
        fetchGenreListCallCount += 1
        if let error = errorStub {
            throw error
        }
        return genreListStub
    }
    
    func searchArtistList(keyword: String?, size: Int?, cursor: String?) async throws(PreferenceError) -> ArtistSearchResult {
        searchArtistListCallCount += 1
        if let error = errorStub {
            throw error
        }
        return artistSearchResultStub
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
