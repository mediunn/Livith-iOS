//
//  SetlistRepositoryImpl.swift
//  ConcertData
//
//  Created by Youjin Lee on 12/25/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import Foundation

import ConcertDomain
import LivithNetwork

public struct SetlistRepositoryImpl {
    private let service: SetlistService
    private let entityMapper: ConcertMapper = .init()
    private let errorMapper: ConcertErrorMapper = .init()

    public init(service: SetlistService = .init()) {
        self.service = service
    }
}

extension SetlistRepositoryImpl: SetlistRepository {
    public func fetchConcertSetlist(setlistID: Int) async throws(ConcertError) -> ConcertSetlist {
        do {
            let response: DTO.Response.FetchConcertSetlist = try await service.request(
                .fetchConcertSetlist(setlistID: setlistID)
            )
            guard let setlist = entityMapper.toDomain(from: response) else {
                throw ConcertError.invalidResponse
            }
            return setlist
        } catch let error as ConcertError {
            throw error
        } catch {
            throw errorMapper.mapToConcertError(error)
        }
    }
}
