//
//  ConcertMatchingRepositoryImpl.swift
//  UserData
//
//  Created by youz2me on 7/8/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

import Domain
import LivithNetworking

public struct ConcertMatchingRepositoryImpl: ConcertMatchingRepository {
    private let networkClient: NetworkClient
    private let mapper: ConcertMatchingMapper = .init()
    private let errorMapper: ConcertMatchingErrorMapper = .init()

    public init(networkClient: NetworkClient) {
        self.networkClient = networkClient
    }

    public func fetchMatchedConcertList(sourceURL: URL) async throws(ConcertMatchingError) -> [Concert] {
        do {
            let response: DTO.Response.CreateExtractionJob = try await networkClient.request(
                InstagramAPI.createExtractionJob(instagramURL: sourceURL.absoluteString)
            )

            switch ExtractionResult(rawValue: response.result) {
            case .matched:
                return mapper.toDomain(from: response)
            case .noMatch:
                return []
            case nil:
                throw ConcertMatchingError.matchFailed
            }
        } catch let error as ConcertMatchingError {
            throw error
        } catch {
            throw errorMapper.mapToConcertMatchingError(error)
        }
    }
}

private extension ConcertMatchingRepositoryImpl {
    enum ExtractionResult: String {
        case matched = "MATCHED"
        case noMatch = "NO_MATCH"
    }
}
