//
//  SearchRepositoryImpl.swift
//  Data
//
//  Created by 김진웅 on 1/21/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

import Domain
import LivithNetworking

struct SearchRepositoryImpl: SearchRepository {
    private let networkClient: NetworkClient
    private let mapper: SearchMapper = .init()
    private let errorMapper: SearchErrorMapper = .init()
    
    init(networkClient: NetworkClient) {
        self.networkClient = networkClient
    }
    
    func fetchBanners() async throws(SearchError) -> [Banner] {
        do {
            let response: DTO.Response.FetchBannerList = try await networkClient.request(
                SearchAPI.fetchBanners()
            )
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
        cursor: Int?,
        size: Int?
    ) async throws(SearchError) -> SearchResult {
        do {
            let response: DTO.Response.FetchFilterSearchResult = try await networkClient.request(
                SearchAPI.fetchFilterSearchResult(
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
            let response: DTO.Response.FetchRecommendKeywordList = try await networkClient.request(
                SearchAPI.fetchRecommendedSearchResult(letter: keyword)
            )
            return response
        } catch let error {
            throw errorMapper.mapToSearchError(error)
        }
    }
}
