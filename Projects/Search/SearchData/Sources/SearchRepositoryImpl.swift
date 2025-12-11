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
    private let service: NetworkService<SearchEndpoint>
    private let entityMapper: SearchMapper
    private let errorMapper: SearchErrorMapper

    public init(
        service: NetworkService<SearchEndpoint> = .init(),
        entityMapper: SearchMapper = .init(),
        errorMapper: SearchErrorMapper = .init()
    ) {
        self.service = service
        self.entityMapper = entityMapper
        self.errorMapper = errorMapper
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
            let endpoint = SearchEndpoint.fetchFilterSearchResult(
                genre: genre,
                sort: sort,
                status: status,
                keyword: keyword,
                cursor: cursor,
                size: size
            )
            let response: DTO.Response.FetchFilterSearchResult = try await service.request(endpoint)

            return entityMapper.toDomain(from: response)
        } catch let error {
            throw errorMapper.mapToSearchError(error)
        }
    }

    public func fetchRecommendedSearchResult(keyword: String) async throws -> [String] {
        do {
            let endpoint = SearchEndpoint.fetchRecommendedSearchResult(letter: keyword)
            let response: DTO.Response.FetchRecommendKeywordList = try await service.request(endpoint)

            return response
        } catch let error {
            throw errorMapper.mapToSearchError(error)
        }
    }
}
