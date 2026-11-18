//
//  SetlistRepository.swift
//  Domain
//
//  Created by 김진웅 on 1/21/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

public protocol SetlistRepository {
    func fetchSetlist(concertID: Int, setlistID: Int) async throws(SetlistError) -> Setlist
    func fetchSetlistSongs(setlistID: Int) async throws(SetlistError) -> [SetlistSong]
}
