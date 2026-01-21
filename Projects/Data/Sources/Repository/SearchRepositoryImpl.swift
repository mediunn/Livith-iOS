//
//  SearchRepositoryImpl.swift
//  Data
//
//  Created by 김진웅 on 1/21/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

import Domain
import LivithNetwork

struct SearchRepositoryImpl: SearchRepository {
    private let searchService: SearchService
    private let mapper: SearchMapper = .init()
    private let errorMapper: SearchErrorMapper = .init()
    
    func fetchBanners() async throws(SearchError) -> [Banner] {
        do {
            let response: DTO.Response.FetchBannerList = try await searchService.request(.fetchBanners)
            return mapper.toDomain(from: response)
        } catch {
            throw errorMapper.mapToSearchError(error)
        }
    }

    func fetchFilterSearchResult(
        genre: [ConcertGenre],
        sort: SearchSort?,
        status: [ConcertStatus],
        keyword: String?,
        cursor: String?,
        size: Int?
    ) async throws(SearchError) -> SearchResultEntity {
        do {
            let response: DTO.Response.FetchFilterSearchResult = try await searchService.request(
                .fetchFilterSearchResult(
                    genre: genre.map(\.rawValue),
                    sort: sort.map(\.rawValue),
                    status: status.map(\.rawValue),
                    keyword: keyword,
                    cursor: cursor,
                    size: size
                )
            )

            return mapper.toDomain(from: response)
        } catch let error {
            throw errorMapper.mapToSearchError(error)
        }
    }

    func fetchRecommendedSearchResult(keyword: String) async throws(SearchError) -> [String] {
        do {
            let response: DTO.Response.FetchRecommendKeywordList = try await searchService.request(
                .fetchRecommendedSearchResult(letter: keyword)
            )
            return response
        } catch let error {
            throw errorMapper.mapToSearchError(error)
        }
    }
}
