//
//  SetlistRepositoryImpl.swift
//  Data
//
//  Created by 김진웅 on 1/21/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

import Domain
import LivithNetwork

public struct SetlistRepositoryImpl: SetlistRepository {
    private let setlistService: SetlistService
    private let mapper: SetlistMapper = .init()
    private let errorMapper: SetlistErrorMapper = .init()
    
    public func fetchSetlist(concertID: Int, setlistID: Int) async throws(SetlistError) -> Setlist {
        do {
            let response: DTO.Response.FetchConcertSetlist = try await setlistService.request(
                .fetchSetlistDetail(concertID: concertID, setlistID: setlistID)
            )
            return mapper.toDomain(from: response)
        } catch {
            throw errorMapper.mapToSetlistError(error)
        }
    }

    public func fetchSetlistSongs(setlistID: Int) async throws(SetlistError) -> [SetlistSong] {
        do {
            let response: DTO.Response.FetchSetlistSongList = try await setlistService.request(
                .fetchSetlistSongList(setlistID: setlistID)
            )
            return mapper.toDomain(from: response)
        } catch {
            throw errorMapper.mapToSetlistError(error)
        }
    }
}
