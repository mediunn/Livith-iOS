//
//  SearchService.swift
//  LivithNetworking
//
//  Created by 김진웅 on 5/27/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

// MARK: - SearchService

public protocol SearchService: Sendable {
    func fetchSections() async throws(NetworkError) -> DTO.Response.FetchSectionList
    func fetchBanners() async throws(NetworkError) -> DTO.Response.FetchBannerList
    func fetchFilterSearchResult(
        genre: [String],
        sort: String?,
        status: [String],
        keyword: String?,
        cursor: Int?,
        size: Int?
    ) async throws(NetworkError) -> DTO.Response.FetchFilterSearchResult
    func fetchRecommendedSearchResult(letter: String) async throws(NetworkError) -> DTO.Response.FetchRecommendKeywordList
    func fetchConcertList(cursor: Int?, size: Int?) async throws(NetworkError) -> DTO.Response.FetchConcertList
}

// MARK: - SearchServiceImpl

struct SearchServiceImpl: SearchService {
    private let networkClient: NetworkClient

    init(networkClient: NetworkClient) {
        self.networkClient = networkClient
    }

    public func fetchSections() async throws(NetworkError) -> DTO.Response.FetchSectionList {
        return try await networkClient.request(
            NetworkEndpoint(
                path: "/search/sections",
                method: .get,
                task: .plain,
                authentication: .none
            )
        )
    }

    public func fetchBanners() async throws(NetworkError) -> DTO.Response.FetchBannerList {
        return try await networkClient.request(
            NetworkEndpoint(
                path: "/search/banners",
                method: .get,
                task: .plain,
                authentication: .none
            )
        )
    }

    public func fetchFilterSearchResult(
        genre: [String],
        sort: String?,
        status: [String],
        keyword: String?,
        cursor: Int?,
        size: Int?
    ) async throws(NetworkError) -> DTO.Response.FetchFilterSearchResult {
        var queryItems: [URLQueryItem] = []

        genre.forEach { queryItems.append(URLQueryItem(name: "genre", value: $0)) }
        status.forEach { queryItems.append(URLQueryItem(name: "status", value: $0)) }
        if let sort {
            queryItems.append(URLQueryItem(name: "sort", value: sort))
        }
        if let keyword {
            queryItems.append(URLQueryItem(name: "keyword", value: keyword))
        }
        if let cursor {
            queryItems.append(URLQueryItem(name: "cursor", value: String(cursor)))
        }
        if let size {
            queryItems.append(URLQueryItem(name: "size", value: String(size)))
        }

        return try await networkClient.request(
            NetworkEndpoint(
                path: "/search/concerts",
                method: .get,
                task: .query(queryItems),
                authentication: .none
            )
        )
    }

    public func fetchRecommendedSearchResult(letter: String) async throws(NetworkError) -> DTO.Response.FetchRecommendKeywordList {
        return try await networkClient.request(
            NetworkEndpoint(
                path: "/search/suggestions",
                method: .get,
                task: .query([URLQueryItem(name: "letter", value: letter)]),
                authentication: .none
            )
        )
    }

    public func fetchConcertList(cursor: Int?, size: Int?) async throws(NetworkError) -> DTO.Response.FetchConcertList {
        var queryItems: [URLQueryItem] = []
        if let cursor {
            queryItems.append(URLQueryItem(name: "cursor", value: String(cursor)))
        }
        if let size {
            queryItems.append(URLQueryItem(name: "size", value: String(size)))
        }

        return try await networkClient.request(
            NetworkEndpoint(
                path: "/concerts",
                method: .get,
                task: .query(queryItems),
                authentication: .none
            )
        )
    }
}
