//
//  MockPreferenceRepository.swift
//  HomeFeatureTests
//
//  Created by 김진웅 on 2/5/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

import Domain

final class MockPreferenceRepository: PreferenceRepository {
    var preferredGenreListStub: [PreferredGenre] = []
    var preferredArtistListStub: [PreferredArtist] = []
    var errorStub: PreferenceError?
    
    var fetchUserPreferredGenreListCallCount: Int = 0
    var fetchUserPreferredArtistListCallCount: Int = 0
    
    func fetchGenreList() async throws(PreferenceError) -> [PreferredGenre] {
        if let error = errorStub {
            throw error
        }
        return []
    }
    
    func searchArtistList(
        keyword: String?,
        size: Int?,
        after nextToken: (any NextToken)?
    ) async throws(PreferenceError) -> ListResult<PreferredArtist> {
        if let error = errorStub {
            throw error
        }
        return ListResult(items: [], nextToken: nil)
    }
    
    func fetchUserPreferredGenreList() async throws(PreferenceError) -> [PreferredGenre] {
        fetchUserPreferredGenreListCallCount += 1
        if let error = errorStub {
            throw error
        }
        return preferredGenreListStub
    }
    
    func fetchUserPreferredArtistList() async throws(PreferenceError) -> [PreferredArtist] {
        fetchUserPreferredArtistListCallCount += 1
        if let error = errorStub {
            throw error
        }
        return preferredArtistListStub
    }
    
    @discardableResult
    func updateUserPreferredGenreList(genreIDs: [Int]) async throws(PreferenceError) -> [PreferredGenre] {
        if let error = errorStub {
            throw error
        }
        return []
    }
    
    @discardableResult
    func updateUserPreferredArtistList(artistIDs: [Int]) async throws(PreferenceError) -> [PreferredArtist] {
        if let error = errorStub {
            throw error
        }
        return []
    }
}
