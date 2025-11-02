//
//  SearchEndpoint.swift
//  search
//
//  Created by Youjin Lee on 10/16/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import Foundation

import Alamofire

import livithnetwork
import searchdomain

public enum SearchEndpoint {
    case fetchFilterSearchResult(
        genre: searchdomain.ConcertGenre?,
        sort: searchdomain.SearchSort?,
        status: searchdomain.ConcertStatus?,
        keyword: String?,
        cursor: String?,
        size: String?
    )
    case fetchRecommendedSearchResult(letter: String)
}

extension SearchEndpoint: NetworkEndpoint {
    public var path: String? {
        switch self {
        case .fetchFilterSearchResult:
            return "/api/v4/search"
        case .fetchRecommendedSearchResult:
            return "/api/v4/search/suggestions"
        }
    }
    
    public var query: [String : Any]? {
        switch self {
        case .fetchFilterSearchResult(
            genre: let genre,
            sort: let sort,
            status: let status,
            keyword: let keyword,
            cursor: let cursor,
            size: let size
        ):
            let params: [String: Any?] = [
                "genre": genre?.rawValue,
                "sort": sort?.rawValue,
                "status": status?.rawValue,
                "keyword": keyword,
                "cursor": cursor,
                "size": size
            ]
            
            return params.compactMapValues { $0 }
        case .fetchRecommendedSearchResult(letter: let letter):
            return ["letter": letter]
        }
    }
    
    public var method: Alamofire.HTTPMethod {
        return .get
    }
}
