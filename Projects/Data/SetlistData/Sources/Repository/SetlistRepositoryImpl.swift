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
    private let setlistService: any SetlistService
    private let mapper: SetlistMapper = .init()
    private let errorMapper: SetlistErrorMapper = .init()
    
    init(setlistService: any SetlistService) {
        self.setlistService = setlistService
    }
    
    func fetchSetlist(concertID: Int, setlistID: Int) async throws(SetlistError) -> Setlist {
        do {
            let response = try await setlistService.fetchSetlistDetail(concertID: concertID, setlistID: setlistID)
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
            let response = try await setlistService.fetchSetlistSongList(setlistID: setlistID)
            return mapper.toDomain(from: response)
        } catch {
            throw errorMapper.mapToSetlistError(error)
        }
    }
}
