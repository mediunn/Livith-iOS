//
//  MockConcertRepository.swift
//  ShareFeatureTests
//
//  Created by Youjin Lee on 7/24/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

import Domain

final class MockConcertRepository: ConcertRepository {
    var requestConcertErrorStub: ConcertError?
    var requestConcertDelay: UInt64 = 0

    var requestConcertCallCount: Int = 0
    var requestConcertTitle: String?
    var requestConcertURL: String?
    var requestConcertAutoRegister: Bool?
    var requestConcertContent: String?

    func requestConcert(
        title: String,
        url: String?,
        autoRegister: Bool,
        requestContent: String?
    ) async throws(ConcertError) {
        requestConcertCallCount += 1
        requestConcertTitle = title
        requestConcertURL = url
        requestConcertAutoRegister = autoRegister
        requestConcertContent = requestContent
        if requestConcertDelay > 0 {
            try? await Task.sleep(nanoseconds: requestConcertDelay)
        }
        if let error = requestConcertErrorStub {
            throw error
        }
    }

    // MARK: - Unused

    func fetchAllConcertList(startDate: Date?, concertID: Int?) async throws(ConcertError) -> [Concert] {
        []
    }

    func fetchAllConcertList(after nextToken: (any NextToken)?, size: Int) async throws(ConcertError) -> ListResult<Concert> {
        ListResult(items: [], nextToken: nil)
    }

    func fetchConcertArtistInfo(concertID: Int) async throws(ConcertError) -> Artist {
        throw ConcertError.serverError
    }

    func fetchConcertSetlistList(concertID: Int) async throws(ConcertError) -> [Setlist] {
        []
    }

    func fetchConcertMerchandiseList(concertID: Int) async throws(ConcertError) -> [ConcertMerchandise] {
        []
    }

    func fetchConcertInfoList(concertID: Int) async throws(ConcertError) -> [ConcertInfo] {
        []
    }

    func fetchConcertCultureList(concertID: Int) async throws(ConcertError) -> [ConcertCulture] {
        []
    }

    func fetchConcertScheduleList(concertID: Int) async throws(ConcertError) -> [ConcertSchedule] {
        []
    }

    func fetchConcert(concertID: Int) async throws(ConcertError) -> Concert {
        throw ConcertError.serverError
    }

    func fetchSearchConcertSectionList() async throws(ConcertError) -> [ConcertSection] {
        []
    }

    func fetchHomeConcertSectionList() async throws(ConcertError) -> [ConcertSection] {
        []
    }

    func fetchMainSetlist(concertID: Int) async throws(ConcertError) -> Setlist? {
        nil
    }

    func fetchRecommendedConcertList() async throws(ConcertError) -> [Concert] {
        []
    }
}
