//
//  SetlistRepositoryImpl.swift
//  Data
//
//  Created by 김진웅 on 1/21/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

import Domain
import LivithNetworking

struct SetlistRepositoryImpl: SetlistRepository {
    private let networkClient: NetworkClient
    private let mapper: SetlistMapper = .init()
    private let errorMapper: SetlistErrorMapper = .init()
    
    init(networkClient: NetworkClient) {
        self.networkClient = networkClient
    }
    
    func fetchSetlist(concertID: Int, setlistID: Int) async throws(SetlistError) -> Setlist {
        do {
            let response: DTO.Response.FetchConcertSetlist = try await networkClient.request(
                SetlistAPI.fetchSetlistDetail(concertID: concertID, setlistID: setlistID)
            )
            guard let setlist = mapper.toDomain(from: response) else {
                throw SetlistError.invalidResponse
            }
            return setlist
        } catch {
            throw errorMapper.mapToSetlistError(error)
        }
    }

    func fetchSetlistSongs(setlistID: Int) async throws(SetlistError) -> [SetlistSong] {
        do {
            let response: DTO.Response.FetchSetlistSongList = try await networkClient.request(
                SetlistAPI.fetchSetlistSongList(setlistID: setlistID)
            )
            return mapper.toDomain(from: response)
        } catch {
            throw errorMapper.mapToSetlistError(error)
        }
    }
}
