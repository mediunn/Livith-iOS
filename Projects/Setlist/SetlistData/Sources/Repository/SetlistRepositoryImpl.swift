//
//  SetlistRepositoryImpl.swift
//  SetlistData
//
//  Created by Youjin Lee on 12/30/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import Foundation

import LivithNetwork
import SetlistDomain

public struct SetlistRepositoryImpl {
    private let service: SetlistService
    private let mapper: SetlistMapper = .init()
    private let errorMapper: SetlistErrorMapper = .init()

    public init(service: SetlistService = .init()) {
        self.service = service
    }
}

extension SetlistRepositoryImpl: SetlistRepository {
    public func fetchSetlist(concertID: Int, setlistID: Int) async throws(SetlistError) -> Setlist {
        do {
            let response: DTO.Response.FetchConcertSetlist = try await service.request(
                .fetchSetlistDetail(concertID: concertID, setlistID: setlistID)
            )
            guard let setlist = mapper.toDomain(from: response) else {
                throw SetlistError.invalidResponse
            }
            return setlist
        } catch let error as SetlistError {
            throw error
        } catch {
            throw errorMapper.mapToSetlistError(error)
        }
    }

    public func fetchSetlistSongs(setlistID: Int) async throws(SetlistError) -> [SetlistSong] {
        do {
            let response: DTO.Response.FetchSetlistSongList = try await service.request(
                .fetchSetlistSongList(setlistID: setlistID)
            )
            return mapper.toDomain(from: response)
        } catch {
            throw errorMapper.mapToSetlistError(error)
        }
    }
}
