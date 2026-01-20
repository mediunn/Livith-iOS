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
    func fetchSections() async throws(SearchError) -> [ConcertSection]
    func fetchFilterSearchResult(
        genre: [ConcertGenre],
        sort: SearchSort?,
        status: [ConcertStatus],
        keyword: String?,
        cursor: String?,
        size: Int?
    ) async throws(SearchError) -> SearchResultEntity
    func fetchRecommendedSearchResult(keyword: String) async throws(SearchError) -> [String]
}
