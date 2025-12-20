//
//  SearchRepositoryImpl.swift
//  search
//
//  Created by Youjin Lee on 10/27/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import Foundation

import LivithNetwork
import SearchDomain

public final class SearchRepositoryImpl {
    private let service: SearchNetworkService
    private let entityMapper: SearchMapper
    private let errorMapper: SearchErrorMapper = .init()

    public init(
        service: SearchNetworkService = .init(),
        entityMapper: SearchMapper = .init()
    ) {
        self.service = service
        self.entityMapper = entityMapper
    }
}

extension SearchRepositoryImpl: SearchRepository {
    public func fetchFilterSearchResult(
        genre: [SearchDomain.ConcertGenre],
        sort: SearchDomain.SearchSort?,
        status: [SearchDomain.ConcertStatus],
        keyword: String?,
        cursor: String?,
        size: Int?
    ) async throws -> SearchDomain.SearchResultEntity {
        do {
            let response: DTO.Response.FetchFilterSearchResult = try await service.request(
                .fetchFilterSearchResult(
                    genre: genre.map(\.rawValue),
                    sort: sort.map(\.rawValue),
                    status: status.map(\.rawValue),
                    keyword: keyword,
                    cursor: cursor,
                    size: size
                )
            )

            return entityMapper.toDomain(from: response)
        } catch let error {
            throw errorMapper.mapToSearchError(error)
        }
    }

    public func fetchRecommendedSearchResult(keyword: String) async throws -> [String] {
        do {
            let response: DTO.Response.FetchRecommendKeywordList = try await service.request(
                .fetchRecommendedSearchResult(letter: keyword)
            )

            return response
        } catch let error {
            throw errorMapper.mapToSearchError(error)
        }
    }
}
