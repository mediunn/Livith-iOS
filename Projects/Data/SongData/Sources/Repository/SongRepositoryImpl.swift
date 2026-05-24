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
    private let songService: any SongService
    private let mapper: SongMapper = .init()
    private let errorMapper: SongErrorMapper = .init()
    
    init(songService: any SongService) {
        self.songService = songService
    }
    
    func fetchSongLyrics(songID: Int) async throws(SongError) -> SongLyrics {
        do {
            let response = try await songService.fetchSongLyrics(songID: songID)
            return mapper.toDomain(from: response)
        } catch {
            throw errorMapper.mapToSongError(error)
        }
    }

    func fetchSongFanchant(setlistID: Int, songID: Int) async throws(SongError) -> SongFanchant {
        do {
            let response = try await songService.fetchSongFanchant(setlistID: setlistID, songID: songID)
            return mapper.toDomain(from: response)
        } catch {
            throw errorMapper.mapToSongError(error)
        }
    }
}
