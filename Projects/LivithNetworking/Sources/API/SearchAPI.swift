//
//  SearchAPI.swift
//  LivithNetworking
//
//  Created by 김진웅 on 5/27/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

public enum SearchAPI {
    public static func fetchSections() -> NetworkEndpoint {
        NetworkEndpoint(
            path: "/search/sections",
            method: .get,
            task: .plain,
            authentication: .none
        )
    }

    public static func fetchBanners() -> NetworkEndpoint {
        NetworkEndpoint(
            path: "/search/banners",
            method: .get,
            task: .plain,
            authentication: .none
        )
    }

    public static func fetchFilterSearchResult(
        genre: [String],
        sort: String?,
        status: [String],
        keyword: String?,
        cursor: Int?,
        size: Int?
    ) -> NetworkEndpoint {
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

        return NetworkEndpoint(
            path: "/search/concerts",
            method: .get,
            task: .query(queryItems),
            authentication: .none
        )
    }

    public static func fetchRecommendedSearchResult(letter: String) -> NetworkEndpoint {
        NetworkEndpoint(
            path: "/search/suggestions",
            method: .get,
            task: .query([URLQueryItem(name: "letter", value: letter)]),
            authentication: .none
        )
    }

    public static func fetchConcertList(cursor: Int?, size: Int?) -> NetworkEndpoint {
        var queryItems: [URLQueryItem] = []
        if let cursor {
            queryItems.append(URLQueryItem(name: "cursor", value: String(cursor)))
        }
        if let size {
            queryItems.append(URLQueryItem(name: "size", value: String(size)))
        }

        return NetworkEndpoint(
            path: "/concerts",
            method: .get,
            task: .query(queryItems),
            authentication: .none
        )
    }
}
