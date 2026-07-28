//
//  SongRepository.swift
//  Domain
//
//  Created by 김진웅 on 1/21/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

public protocol SongRepository {
    func fetchSongLyrics(songID: Int) async throws(SongError) -> SongLyrics
    func fetchSongFanchant(setlistID: Int, songID: Int) async throws(SongError) -> SongFanchant
}
