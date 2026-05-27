//
//  SetlistService.swift
//  LivithNetworking
//
//  Created by 김진웅 on 5/27/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

// MARK: - SetlistService

public protocol SetlistService: Sendable {
    func fetchSetlistDetail(concertID: Int, setlistID: Int) async throws(NetworkError) -> DTO.Response.FetchConcertSetlist
    func fetchSetlistSongList(setlistID: Int) async throws(NetworkError) -> DTO.Response.FetchSetlistSongList
    func fetchConcertMainSetlist(concertID: Int) async throws(NetworkError) -> DTO.Response.FetchConcertSetlist
}

// MARK: - SetlistServiceImpl

struct SetlistServiceImpl: SetlistService {
    private let networkClient: NetworkClient

    init(networkClient: NetworkClient) {
        self.networkClient = networkClient
    }

    public func fetchSetlistDetail(concertID: Int, setlistID: Int) async throws(NetworkError) -> DTO.Response.FetchConcertSetlist {
        return try await networkClient.request(
            NetworkEndpoint(
                path: "/concerts/\(concertID)/setlists/\(setlistID)",
                method: .get,
                task: .plain,
                authentication: .none
            )
        )
    }

    public func fetchSetlistSongList(setlistID: Int) async throws(NetworkError) -> DTO.Response.FetchSetlistSongList {
        return try await networkClient.request(
            NetworkEndpoint(
                path: "/setlists/\(setlistID)/songs",
                method: .get,
                task: .plain,
                authentication: .none
            )
        )
    }

    public func fetchConcertMainSetlist(concertID: Int) async throws(NetworkError) -> DTO.Response.FetchConcertSetlist {
        return try await networkClient.request(
            NetworkEndpoint(
                path: "/concerts/\(concertID)/main-setlist",
                method: .get,
                task: .plain,
                authentication: .none
            )
        )
    }
}
