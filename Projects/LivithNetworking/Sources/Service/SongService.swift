//
//  SongService.swift
//  LivithNetworking
//
//  Created by 김진웅 on 5/24/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

// MARK: - SongService

public protocol SongService: Sendable {
    func fetchSongLyrics(songID: Int) async throws(NetworkError) -> DTO.Response.FetchSongLyrics
    func fetchSongFanchant(setlistID: Int, songID: Int) async throws(NetworkError) -> DTO.Response.FetchSongFanchant
}

// MARK: - SongServiceImpl

struct SongServiceImpl: SongService {
    private let networkClient: NetworkClient

    init(networkClient: NetworkClient) {
        self.networkClient = networkClient
    }

    public func fetchSongLyrics(songID: Int) async throws(NetworkError) -> DTO.Response.FetchSongLyrics {
        return try await networkClient.request(
            NetworkEndpoint(
                path: "/songs/\(songID)",
                method: .get,
                task: .plain,
                authentication: .none,
                cache: .enabled
            )
        )
    }

    public func fetchSongFanchant(setlistID: Int, songID: Int) async throws(NetworkError) -> DTO.Response.FetchSongFanchant {
        return try await networkClient.request(
            NetworkEndpoint(
                path: "/setlists/\(setlistID)/songs/\(songID)/fanchant",
                method: .get,
                task: .plain,
                authentication: .none
            )
        )
    }
}
