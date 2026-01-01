//
//  SetlistRepository.swift
//  SetlistDomain
//
//  Created by Youjin Lee on 12/30/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import Foundation

public protocol SetlistRepository {
    func fetchSetlist(concertID: Int, setlistID: Int) async throws(SetlistError) -> Setlist
    func fetchSetlistSongs(setlistID: Int) async throws(SetlistError) -> [SetlistSong]
}
