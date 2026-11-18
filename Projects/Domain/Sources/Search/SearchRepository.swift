//
//  SearchRepository.swift
//  Domain
//
//  Created by 김진웅 on 1/21/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

public protocol SearchRepository {
    func fetchBanners() async throws(SearchError) -> [Banner]
    func fetchFilterSearchResult(
        genre: [ConcertGenre],
        sort: SearchSort?,
        status: [ConcertStatus],
        keyword: String?,
        after nextToken: (any NextToken)?,
        size: Int?
    ) async throws(SearchError) -> ListResult<Concert>
    func fetchRecommendedSearchResult(keyword: String) async throws(SearchError) -> [String]
}
