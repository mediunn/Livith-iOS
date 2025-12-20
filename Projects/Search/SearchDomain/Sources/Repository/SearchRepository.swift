//
//  SearchRepository.swift
//  search
//
//  Created by Youjin Lee on 10/27/25.
//  Copyright © 2025 Livith. All rights reserved.
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
