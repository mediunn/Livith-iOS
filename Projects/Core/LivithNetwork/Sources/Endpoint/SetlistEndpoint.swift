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
    case fetchSetlistSongList(setlistID: Int)
}

extension SetlistEndpoint: NetworkEndpoint {
    public var path: String? {
        switch self {
        case .fetchConcertSetlist(let setlistID):
            return "/api/v4/setlists/\(setlistID)"
        case .fetchSetlistSongList(let setlistID):
            return "/api/v4/setlists/\(setlistID)/songs"
        }
    }

    public var query: [String: Any]? {
        switch self {
        case .fetchConcertSetlist, .fetchSetlistSongList:
            return nil
        }
    }

    public var method: HTTPMethod {
        switch self {
        case .fetchConcertSetlist, .fetchSetlistSongList:
            return .get
        }
    }

    public var headers: HTTPHeaders? {
        switch self {
        case .fetchConcertSetlist, .fetchSetlistSongList:
            return nil
        }
    }

    public var body: Encodable? {
        switch self {
        case .fetchConcertSetlist, .fetchSetlistSongList:
            return nil
        }
    }

    public var requiresInterceptor: Bool {
        switch self {
        case .fetchConcertSetlist, .fetchSetlistSongList:
            return false
        }
    }
}
