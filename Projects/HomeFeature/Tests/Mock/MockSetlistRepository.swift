//
//  MockSetlistRepository.swift
//  HomeFeatureTests
//
//  Created by 김진웅 on 2/5/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

import Domain

final class MockSetlistRepository: SetlistRepository {
    var setlistStub: Setlist?
    var setlistSongsStub: [SetlistSong] = []
    var errorStub: SetlistError?
    
    var fetchSetlistCallCount: Int = 0
    var fetchSetlistSongsCallCount: Int = 0
    
    func fetchSetlist(concertID: Int, setlistID: Int) async throws(SetlistError) -> Setlist {
        fetchSetlistCallCount += 1
        if let error = errorStub {
            throw error
        }
        guard let setlist = setlistStub else {
            throw SetlistError.serverError
        }
        return setlist
    }
    
    func fetchSetlistSongs(setlistID: Int) async throws(SetlistError) -> [SetlistSong] {
        fetchSetlistSongsCallCount += 1
        if let error = errorStub {
            throw error
        }
        return setlistSongsStub
    }
}
