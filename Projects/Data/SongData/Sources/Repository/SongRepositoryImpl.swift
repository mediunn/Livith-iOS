//
//  SongRepositoryImpl.swift
//  Data
//
//  Created by 김진웅 on 1/21/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

import Domain
import LivithNetworking

struct SongRepositoryImpl: SongRepository {
    private let networkClient: NetworkClient
    private let mapper: SongMapper = .init()
    private let errorMapper: SongErrorMapper = .init()
    
    init(networkClient: NetworkClient) {
        self.networkClient = networkClient
    }
    
    func fetchSongLyrics(songID: Int) async throws(SongError) -> SongLyrics {
        do {
            let response: DTO.Response.FetchSongLyrics = try await networkClient.request(
                SongAPI.fetchSongLyrics(songID: songID)
            )
            return mapper.toDomain(from: response)
        } catch {
            throw errorMapper.mapToSongError(error)
        }
    }

    func fetchSongFanchant(setlistID: Int, songID: Int) async throws(SongError) -> SongFanchant {
        do {
            let response: DTO.Response.FetchSongFanchant = try await networkClient.request(
                SongAPI.fetchSongFanchant(setlistID: setlistID, songID: songID)
            )
            return mapper.toDomain(from: response)
        } catch {
            throw errorMapper.mapToSongError(error)
        }
    }
}
