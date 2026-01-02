//
//  SetlistEndpoint.swift
//  LivithNetwork
//
//  Created by Youjin Lee on 12/25/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import Foundation

public typealias SetlistService = NetworkService<SetlistEndpoint>

public enum SetlistEndpoint {
    case fetchConcertSetlist(setlistID: Int)
    case fetchSetlistDetail(concertID: Int, setlistID: Int)
    case fetchSetlistSongList(setlistID: Int)
    case fetchConcertMainSetlist(concertID: Int)
}

extension SetlistEndpoint: NetworkEndpoint {
    public var path: String? {
        switch self {
        case .fetchConcertSetlist(let setlistID):
            return "/api/v4/setlists/\(setlistID)"
        case .fetchSetlistDetail(let concertID, let setlistID):
            return "/api/v4/concerts/\(concertID)/setlists/\(setlistID)"
        case .fetchSetlistSongList(let setlistID):
            return "/api/v4/setlists/\(setlistID)/songs"
        case .fetchConcertMainSetlist(let concertID):
            return "/api/v4/concerts/\(concertID)/main-setlist"
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
