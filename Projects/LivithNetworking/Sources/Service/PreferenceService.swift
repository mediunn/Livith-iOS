//
//  PreferenceService.swift
//  LivithNetworking
//
//  Created by 김진웅 on 5/27/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

// MARK: - PreferenceService

public protocol PreferenceService: Sendable {
    func fetchGenreList() async throws(NetworkError) -> DTO.Response.FetchGenreList
    func searchArtistList(keyword: String?, size: Int?, cursor: String?) async throws(NetworkError) -> DTO.Response.SearchArtistList
    func fetchUserPreferredGenreList() async throws(NetworkError) -> DTO.Response.FetchUserPreferredGenreList
    func fetchUserPreferredArtistList() async throws(NetworkError) -> DTO.Response.FetchUserPreferredArtistList
    func updateUserPreferredGenreList(genreIDs: [Int]) async throws(NetworkError) -> DTO.Response.UpdateUserPreferredGenreList
    func updateUserPreferredArtistList(artistIDs: [Int]) async throws(NetworkError) -> DTO.Response.UpdateUserPreferredArtistList
}

// MARK: - PreferenceServiceImpl

struct PreferenceServiceImpl: PreferenceService {
    private let networkClient: NetworkClient

    init(networkClient: NetworkClient) {
        self.networkClient = networkClient
    }

    public func fetchGenreList() async throws(NetworkError) -> DTO.Response.FetchGenreList {
        return try await networkClient.request(
            NetworkEndpoint(
                path: "/genres",
                method: .get,
                task: .plain,
                authentication: .none
            )
        )
    }

    public func searchArtistList(keyword: String?, size: Int?, cursor: String?) async throws(NetworkError) -> DTO.Response.SearchArtistList {
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

        return try await networkClient.request(
            NetworkEndpoint(
                path: "/search/artists",
                method: .get,
                task: .query(queryItems),
                authentication: .none
            )
        )
    }

    public func fetchUserPreferredGenreList() async throws(NetworkError) -> DTO.Response.FetchUserPreferredGenreList {
        return try await networkClient.request(
            NetworkEndpoint(
                path: "/users/genre-preferences",
                method: .get,
                task: .plain,
                authentication: .required
            )
        )
    }

    public func fetchUserPreferredArtistList() async throws(NetworkError) -> DTO.Response.FetchUserPreferredArtistList {
        return try await networkClient.request(
            NetworkEndpoint(
                path: "/users/artist-preferences",
                method: .get,
                task: .plain,
                authentication: .required
            )
        )
    }

    public func updateUserPreferredGenreList(genreIDs: [Int]) async throws(NetworkError) -> DTO.Response.UpdateUserPreferredGenreList {
        return try await networkClient.request(
            NetworkEndpoint(
                path: "/users/genre-preferences",
                method: .put,
                task: .body(DTO.Request.UpdateUserPreferredGenreList(genreIDs: genreIDs)),
                authentication: .required
            )
        )
    }

    public func updateUserPreferredArtistList(artistIDs: [Int]) async throws(NetworkError) -> DTO.Response.UpdateUserPreferredArtistList {
        return try await networkClient.request(
            NetworkEndpoint(
                path: "/users/artist-preferences",
                method: .put,
                task: .body(DTO.Request.UpdateUserPreferredArtistList(artistIDs: artistIDs)),
                authentication: .required
            )
        )
    }
}
