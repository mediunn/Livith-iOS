//
//  SearchRepository.swift
//  search
//
//  Created by Youjin Lee on 10/27/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import Foundation

public protocol SearchRepository {
    func fetchFilterSearchResult(
        genre: ConcertGenre?,
        sort: SearchSort?,
        status: ConcertStatus?,
        keyword: String?,
        cursor: String?,
        size: String?
    ) async throws -> [ConcertEntity]
    func fetchRecommendedSearchResult(keyword: String) async throws -> [String]
}
