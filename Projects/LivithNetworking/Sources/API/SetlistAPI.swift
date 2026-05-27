//
//  SetlistAPI.swift
//  LivithNetworking
//
//  Created by 김진웅 on 5/27/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

public enum SetlistAPI {
    public static func fetchSetlistDetail(concertID: Int, setlistID: Int) -> NetworkEndpoint {
        NetworkEndpoint(
            path: "/concerts/\(concertID)/setlists/\(setlistID)",
            method: .get,
            task: .plain,
            authentication: .none
        )
    }

    public static func fetchSetlistSongList(setlistID: Int) -> NetworkEndpoint {
        NetworkEndpoint(
            path: "/setlists/\(setlistID)/songs",
            method: .get,
            task: .plain,
            authentication: .none
        )
    }

    public static func fetchConcertMainSetlist(concertID: Int) -> NetworkEndpoint {
        NetworkEndpoint(
            path: "/concerts/\(concertID)/main-setlist",
            method: .get,
            task: .plain,
            authentication: .none
        )
    }
}
