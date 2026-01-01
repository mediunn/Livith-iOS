//
//  SongRepository.swift
//  SongDomain
//
//  Created by Youjin Lee on 1/1/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

public protocol SongRepository {
    func fetchSongLyrics(songID: Int) async throws(SongError) -> SongLyrics
    func fetchSongFanchant(setlistID: Int, songID: Int) async throws(SongError) -> SongFanchant
}
