//
//  PreferenceAPI.swift
//  LivithNetworking
//
//  Created by 김진웅 on 5/27/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

public enum PreferenceAPI {
    public static func fetchGenreList() -> NetworkEndpoint {
        NetworkEndpoint(
            path: "/genres",
            method: .get,
            task: .plain,
            authentication: .none
        )
    }

    public static func searchArtistList(keyword: String?, size: Int?, cursor: String?) -> NetworkEndpoint {
        var queryItems: [URLQueryItem] = []
        if let keyword {
            queryItems.append(URLQueryItem(name: "keyword", value: keyword))
        }
        if let size {
            queryItems.append(URLQueryItem(name: "size", value: String(size)))
        }
        if let cursor {
            queryItems.append(URLQueryItem(name: "cursor", value: cursor))
        }

        return NetworkEndpoint(
            path: "/search/artists",
            method: .get,
            task: .query(queryItems),
            authentication: .none
        )
    }

    public static func fetchUserPreferredGenreList() -> NetworkEndpoint {
        NetworkEndpoint(
            path: "/users/genre-preferences",
            method: .get,
            task: .plain,
            authentication: .required
        )
    }

    public static func fetchUserPreferredArtistList() -> NetworkEndpoint {
        NetworkEndpoint(
            path: "/users/artist-preferences",
            method: .get,
            task: .plain,
            authentication: .required
        )
    }

    public static func updateUserPreferredGenreList(genreIDs: [Int]) -> NetworkEndpoint {
        NetworkEndpoint(
            path: "/users/genre-preferences",
            method: .put,
            task: .body(DTO.Request.UpdateUserPreferredGenreList(genreIDs: genreIDs)),
            authentication: .required
        )
    }

    public static func updateUserPreferredArtistList(artistIDs: [Int]) -> NetworkEndpoint {
        NetworkEndpoint(
            path: "/users/artist-preferences",
            method: .put,
            task: .body(DTO.Request.UpdateUserPreferredArtistList(artistIDs: artistIDs)),
            authentication: .required
        )
    }
}
