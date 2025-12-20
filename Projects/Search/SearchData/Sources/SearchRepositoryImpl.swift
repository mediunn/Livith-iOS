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

public struct SearchRepositoryImpl {
    private let service: SearchNetworkService
    private let entityMapper: SearchMapper = .init()
    private let errorMapper: SearchErrorMapper = .init()

    public init(service: SearchNetworkService = .init()) {
        self.service = service
    }
}

extension SearchRepositoryImpl: SearchRepository {
    public func fetchBanners() async throws(SearchError) -> [Banner] {
        do {
            let response: DTO.Response.Banners = try await service.request(.fetchBanners)
            return entityMapper.toDomain(from: response)
        } catch {
            throw errorMapper.mapToSearchError(error)
        }
    }
    
    public func fetchSections() async throws(SearchError) -> [ConcertSection] {
        do {
            let response: DTO.Response.Sections = try await service.request(.fetchSections)
            return entityMapper.toDomain(from: response)
        } catch {
            throw errorMapper.mapToSearchError(error)
        }
    }
    
    public func fetchFilterSearchResult(
        genre: [SearchDomain.ConcertGenre],
        sort: SearchDomain.SearchSort?,
        status: [SearchDomain.ConcertStatus],
        keyword: String?,
        cursor: String?,
        size: Int?
    ) async throws(SearchError) -> SearchDomain.SearchResultEntity {
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

    public func fetchRecommendedSearchResult(keyword: String) async throws(SearchError) -> [String] {
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
