//
//  PreferenceEndpoint.swift
//  LivithNetwork
//
//  Created by 김진웅 on 2/4/2026.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

public typealias PreferenceService = NetworkService<PreferenceEndpoint>

public enum PreferenceEndpoint {
    case fetchGenreList
    case fetchArtistList(keyword: String?, size: Int?, cursor: String?)
    case fetchUserPreferredGenreList
    case fetchUserPreferredArtistList
    case updateUserPreferredGenreList(genreIDs: [Int])
    case updateUserPreferredArtistList(artistIDs: [Int])
}

extension PreferenceEndpoint: NetworkEndpoint {
    public var path: String? {
        switch self {
        case .fetchGenreList:
            return "/genres"
        case .fetchArtistList:
            return "/artists"
        case .fetchUserPreferredGenreList, .updateUserPreferredGenreList:
            return "/users/genre-preferences"
        case .fetchUserPreferredArtistList, .updateUserPreferredArtistList:
            return "/users/artist-preferences"
        }
    }
    
    public var method: HTTPMethod {
        switch self {
        case .fetchGenreList, .fetchArtistList, .fetchUserPreferredGenreList, .fetchUserPreferredArtistList:
            return .get
        case .updateUserPreferredGenreList, .updateUserPreferredArtistList:
            return .put
        }
    }
    
    public var query: [String: Any]? {
        switch self {
        case .fetchArtistList(let keyword, let size, let cursor):
            let query: [String: Any?] = [
                "cursor": cursor,
                "size": size,
                "keyword": keyword
            ]
            return query.compactMapValues { $0 }
        default:
            return nil
        }
    }

    public var body: Encodable? {
        switch self {
        case .updateUserPreferredGenreList(let genreIDs):
            return DTO.Request.UpdateUserPreferredGenreList(genreIDs: genreIDs)
        case .updateUserPreferredArtistList(let artistIDs):
            return DTO.Request.UpdateUserPreferredArtistList(artistIDs: artistIDs)
        default:
            return nil
        }
    }
    
    public var requiresInterceptor: Bool {
        switch self {
        case .fetchGenreList, .fetchArtistList:
            return false
        case .fetchUserPreferredGenreList, .fetchUserPreferredArtistList,
             .updateUserPreferredGenreList, .updateUserPreferredArtistList:
            return true
        }
    }
}
