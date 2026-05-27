//
//  SongAPI.swift
//  LivithNetworking
//
//  Created by 김진웅 on 5/27/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

public enum SongAPI {
    public static func fetchSongLyrics(songID: Int) -> NetworkEndpoint {
        NetworkEndpoint(
            path: "/songs/\(songID)",
            method: .get,
            task: .plain,
            authentication: .none
        )
    }

    public static func fetchSongFanchant(setlistID: Int, songID: Int) -> NetworkEndpoint {
        NetworkEndpoint(
            path: "/setlists/\(setlistID)/songs/\(songID)/fanchant",
            method: .get,
            task: .plain,
            authentication: .none
        )
    }
}
