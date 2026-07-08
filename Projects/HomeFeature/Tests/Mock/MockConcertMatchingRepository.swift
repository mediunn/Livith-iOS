//
//  MockConcertMatchingRepository.swift
//  HomeFeatureTests
//
//  Created by youz2me on 7/8/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

import Domain

final class MockConcertMatchingRepository: ConcertMatchingRepository {
    var matchedConcertListResultQueue: [Result<[Concert], ConcertMatchingError>] = []
    var fetchMatchedConcertListCallCount: Int = 0
    var fetchMatchedConcertListSourceURLList: [URL] = []

    func fetchMatchedConcertList(sourceURL: URL) async throws(ConcertMatchingError) -> [Concert] {
        let queuedResult: Result<[Concert], ConcertMatchingError>? = await MainActor.run {
            fetchMatchedConcertListCallCount += 1
            fetchMatchedConcertListSourceURLList.append(sourceURL)

            guard !matchedConcertListResultQueue.isEmpty else { return nil }

            return matchedConcertListResultQueue.removeFirst()
        }

        guard let queuedResult else {
            throw ConcertMatchingError.matchFailed
        }

        switch queuedResult {
        case .success(let concertList):
            return concertList
        case .failure(let error):
            throw error
        }
    }
}
