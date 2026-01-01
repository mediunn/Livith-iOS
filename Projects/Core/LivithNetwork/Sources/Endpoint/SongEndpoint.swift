//
//  SongEndpoint.swift
//  LivithNetwork
//
//  Created by Youjin Lee on 1/1/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

public typealias SongService = NetworkService<SongEndpoint>

public enum SongEndpoint {
    case fetchSongLyrics(songID: Int)
    case fetchSongFanchant(setlistID: Int, songID: Int)
}

extension SongEndpoint: NetworkEndpoint {
    public var path: String? {
        switch self {
        case .fetchSongLyrics(let songID):
            return "/api/v4/songs/\(songID)"
        case .fetchSongFanchant(let setlistID, let songID):
            return "/api/v4/setlists/\(setlistID)/songs/\(songID)/fanchant"
        }
    }

    public var query: [String: Any]? {
        return nil
    }

    public var method: HTTPMethod {
        return .get
    }

    public var headers: HTTPHeaders? {
        return nil
    }

    public var body: Encodable? {
        return nil
    }

    public var requiresInterceptor: Bool {
        return false
    }
}
