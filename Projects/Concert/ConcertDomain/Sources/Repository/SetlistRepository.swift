//
//  SetlistRepository.swift
//  ConcertDomain
//
//  Created by Youjin Lee on 12/25/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import Foundation

public protocol SetlistRepository {
    func fetchConcertSetlist(setlistID: Int) async throws(ConcertError) -> ConcertSetlist
    func fetchSetlistSongList(setlistID: Int) async throws(ConcertError) -> [SetlistSong]
}
