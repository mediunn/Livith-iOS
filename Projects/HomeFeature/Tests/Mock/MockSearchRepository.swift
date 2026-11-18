//
//  MockSearchRepository.swift
//  HomeFeatureTests
//
//  Created by 김진웅 on 5/1/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

import Domain

final class MockSearchRepository: SearchRepository {
    var bannerStub: [Banner] = []
    var recommendedSearchResultStub: [String] = []
    var searchResultStub: ListResult<Concert>?
    var searchResultQueue: [Result<ListResult<Concert>, SearchError>] = []
    var fetchFilterSearchResultDelayQueue: [UInt64] = []
    var errorStub: SearchError?

    var fetchFilterSearchResultCallCount: Int = 0
    var fetchFilterSearchResultGenreList: [[ConcertGenre]] = []
    var fetchFilterSearchResultSortList: [SearchSort?] = []
    var fetchFilterSearchResultStatusList: [[ConcertStatus]] = []
    var fetchFilterSearchResultKeywordList: [String?] = []
    var fetchFilterSearchResultPositionValueList: [Int?] = []
    var fetchFilterSearchResultSizeList: [Int?] = []

    func fetchBanners() async throws(SearchError) -> [Banner] {
        if let errorStub {
            throw errorStub
        }
        return bannerStub
    }

    func fetchFilterSearchResult(
        genre: [ConcertGenre],
        sort: SearchSort?,
        status: [ConcertStatus],
        keyword: String?,
        after position: (any PagePosition)?,
        size: Int?
    ) async throws(SearchError) -> ListResult<Concert> {
        let delay: UInt64
        if !fetchFilterSearchResultDelayQueue.isEmpty {
            delay = fetchFilterSearchResultDelayQueue.removeFirst()
        } else {
            delay = 0
        }

        fetchFilterSearchResultCallCount += 1
        fetchFilterSearchResultGenreList.append(genre)
        fetchFilterSearchResultSortList.append(sort)
        fetchFilterSearchResultStatusList.append(status)
        fetchFilterSearchResultKeywordList.append(keyword)
        fetchFilterSearchResultPositionValueList.append((position as? TestSearchPosition)?.value)
        fetchFilterSearchResultSizeList.append(size)

        if delay > 0 {
            try? await Task.sleep(nanoseconds: delay)
        }

        if !searchResultQueue.isEmpty {
            switch searchResultQueue.removeFirst() {
            case .success(let searchResult):
                return searchResult
            case .failure(let error):
                throw error
            }
        }

        if let errorStub {
            throw errorStub
        }

        if let searchResultStub {
            return searchResultStub
        }

        return ListResult(items: [], position: nil)
    }

    func fetchRecommendedSearchResult(keyword: String) async throws(SearchError) -> [String] {
        if let errorStub {
            throw errorStub
        }
        return recommendedSearchResultStub
    }
}

struct TestSearchPosition: PagePosition {
    let value: Int
}
