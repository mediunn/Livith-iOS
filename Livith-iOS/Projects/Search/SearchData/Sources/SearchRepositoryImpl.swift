//
//  SearchRepositoryImpl.swift
//  search
//
//  Created by Youjin Lee on 10/27/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import Foundation

import livithnetwork
import searchdomain

public final class SearchRepositoryImpl {
    private let service: NetworkService<SearchEndpoint> = .init()
}

extension SearchRepositoryImpl: SearchRepository {
    public func fetchFilterSearchResult(
        genre: searchdomain.ConcertGenre?,
        sort: searchdomain.SearchSort?,
        status: searchdomain.ConcertStatus?,
        keyword: String?,
        cursor: String?,
        size: String?
    ) -> [searchdomain.ConcertEntity] {
        return service.request(.fetchFilterSearchResult)
    }
    
    public func fetchRecommendedSearchResult(keyword: String) -> [String] {
        <#code#>
    }
}
