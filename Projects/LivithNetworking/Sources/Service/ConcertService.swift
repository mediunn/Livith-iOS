//
//  ConcertService.swift
//  LivithNetworking
//
//  Created by 김진웅 on 5/27/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

// MARK: - ConcertService

public protocol ConcertService: Sendable {
    func fetchConcertInfo(concertID: Int) async throws(NetworkError) -> DTO.Response.FetchConcertInfo
    func fetchConcertSchedule(concertID: Int) async throws(NetworkError) -> DTO.Response.FetchConcertSchedule
    func fetchConcertCultureList(concertID: Int) async throws(NetworkError) -> DTO.Response.FetchConcertCultureList
    func fetchConcertInfoList(concertID: Int) async throws(NetworkError) -> DTO.Response.FetchConcertInfoList
    func fetchConcertMerchandiseList(concertID: Int) async throws(NetworkError) -> DTO.Response.FetchConcertMerchandiseList
    func fetchConcertSetlistList(concertID: Int) async throws(NetworkError) -> DTO.Response.FetchConcertSetlistList
    func fetchConcertArtistInfo(concertID: Int) async throws(NetworkError) -> DTO.Response.FetchConcertArtistInfo
}

// MARK: - ConcertServiceImpl

struct ConcertServiceImpl: ConcertService {
    private let networkClient: NetworkClient

    init(networkClient: NetworkClient) {
        self.networkClient = networkClient
    }

    public func fetchConcertInfo(concertID: Int) async throws(NetworkError) -> DTO.Response.FetchConcertInfo {
        return try await networkClient.request(
            NetworkEndpoint(
                path: "/concerts/\(concertID)",
                method: .get,
                task: .plain,
                authentication: .none
            )
        )
    }

    public func fetchConcertSchedule(concertID: Int) async throws(NetworkError) -> DTO.Response.FetchConcertSchedule {
        return try await networkClient.request(
            NetworkEndpoint(
                path: "/concerts/\(concertID)/schedule",
                method: .get,
                task: .plain,
                authentication: .none
            )
        )
    }

    public func fetchConcertCultureList(concertID: Int) async throws(NetworkError) -> DTO.Response.FetchConcertCultureList {
        return try await networkClient.request(
            NetworkEndpoint(
                path: "/concerts/\(concertID)/cultures",
                method: .get,
                task: .plain,
                authentication: .none
            )
        )
    }

    public func fetchConcertInfoList(concertID: Int) async throws(NetworkError) -> DTO.Response.FetchConcertInfoList {
        return try await networkClient.request(
            NetworkEndpoint(
                path: "/concerts/\(concertID)/info",
                method: .get,
                task: .plain,
                authentication: .none
            )
        )
    }

    public func fetchConcertMerchandiseList(concertID: Int) async throws(NetworkError) -> DTO.Response.FetchConcertMerchandiseList {
        return try await networkClient.request(
            NetworkEndpoint(
                path: "/concerts/\(concertID)/mds",
                method: .get,
                task: .plain,
                authentication: .none
            )
        )
    }

    public func fetchConcertSetlistList(concertID: Int) async throws(NetworkError) -> DTO.Response.FetchConcertSetlistList {
        return try await networkClient.request(
            NetworkEndpoint(
                path: "/concerts/\(concertID)/setlists",
                method: .get,
                task: .plain,
                authentication: .none
            )
        )
    }

    public func fetchConcertArtistInfo(concertID: Int) async throws(NetworkError) -> DTO.Response.FetchConcertArtistInfo {
        return try await networkClient.request(
            NetworkEndpoint(
                path: "/concerts/\(concertID)/artist",
                method: .get,
                task: .plain,
                authentication: .none
            )
        )
    }
}
