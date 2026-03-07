//
//  SearchEndpoint.swift
//  LivithNetwork
//
//  Created by 김진웅 on 12/20/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import Foundation

public typealias SearchService = NetworkService<SearchEndpoint>

public enum SearchEndpoint {
    case fetchSections
    case fetchBanners
    case fetchFilterSearchResult(
        genre: [String],
        sort: String?,
        status: [String],
        keyword: String?,
        cursor: String?,
        size: Int?
    )
    case fetchRecommendedSearchResult(letter: String)
    case fetchConcertList(
        cursor: Int?,
        size: Int?
    )
}

extension SearchEndpoint: NetworkEndpoint {
    public var path: String? {
        switch self {
        case .fetchSections:
            return "/search/sections"
        case .fetchBanners:
            return "/search/banners"
        case .fetchFilterSearchResult:
            return "/search/concerts"
        case .fetchRecommendedSearchResult:
            return "/search/suggestions"
        case .fetchConcertList:
            return "/concerts"
        }
    }

    public var query: [String : Any]? {
        switch self {
        case .fetchSections, .fetchBanners:
            return nil
        case .fetchFilterSearchResult(
            genre: let genre,
            sort: let sort,
            status: let status,
            keyword: let keyword,
            cursor: let cursor,
            size: let size):
            let params: [String: Any?] = [
                "genre": genre,
                "sort": sort,
                "status": status,
                "keyword": keyword,
                "cursor": cursor,
                "size": size
            ]

            return params.compactMapValues { $0 }
        case .fetchRecommendedSearchResult(letter: let letter):
            return ["letter": letter]
        case .fetchConcertList(
            cursor: let cursor,
            size: let size):
            let params: [String: Any?] = [
                "cursor": cursor,
                "size": size
            ]

            return params.compactMapValues { $0 }
        }
    }

    public var method: HTTPMethod {
        switch self {
        case .fetchSections, .fetchBanners, .fetchFilterSearchResult, .fetchRecommendedSearchResult, .fetchConcertList:
            return .get
        }
    }

    public var headers: HTTPHeaders? {
        switch self {
        case .fetchSections, .fetchBanners, .fetchFilterSearchResult, .fetchRecommendedSearchResult, .fetchConcertList:
            return nil
        }
    }

    public var body: Encodable? {
        switch self {
        case .fetchSections, .fetchBanners, .fetchFilterSearchResult, .fetchRecommendedSearchResult, .fetchConcertList:
            return nil
        }
    }

    public var requiresInterceptor: Bool {
        switch self {
        case .fetchSections, .fetchBanners, .fetchFilterSearchResult, .fetchRecommendedSearchResult, .fetchConcertList:
            return false
        }
    }
}
