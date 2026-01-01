//
//  SongRepositoryImpl.swift
//  SongData
//
//  Created by Youjin Lee on 1/1/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

import LivithNetwork
import SongDomain

public struct SongRepositoryImpl {
    private let service: SongService
    private let mapper: SongMapper = .init()
    private let errorMapper: SongErrorMapper = .init()

    public init(service: SongService = .init()) {
        self.service = service
    }
}

extension SongRepositoryImpl: SongRepository {
    public func fetchSongLyrics(songID: Int) async throws(SongError) -> SongLyrics {
        do {
            let response: DTO.Response.FetchSongLyrics = try await service.request(
                .fetchSongLyrics(songID: songID)
            )
            return mapper.toDomain(from: response)
        } catch {
            throw errorMapper.mapToSongError(error)
        }
    }

    public func fetchSongFanchant(setlistID: Int, songID: Int) async throws(SongError) -> SongFanchant {
        do {
            let response: DTO.Response.FetchSongFanchant = try await service.request(
                .fetchSongFanchant(setlistID: setlistID, songID: songID)
            )
            return mapper.toDomain(from: response)
        } catch {
            throw errorMapper.mapToSongError(error)
        }
    }
}
