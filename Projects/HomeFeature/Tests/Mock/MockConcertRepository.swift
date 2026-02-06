//
//  MockConcertRepository.swift
//  HomeFeatureTests
//
//  Created by 김진웅 on 2/5/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

import Domain

final class MockConcertRepository: ConcertRepository {
    var concertListStub: [Concert] = []
    var artistStub: Artist?
    var setlistListStub: [Setlist] = []
    var merchandiseListStub: [ConcertMerchandise] = []
    var infoListStub: [ConcertInfo] = []
    var cultureListStub: [ConcertCulture] = []
    var scheduleListStub: [ConcertSchedule] = []
    var concertStub: Concert?
    var searchSectionListStub: [ConcertSection] = []
    var homeSectionListStub: [ConcertSection] = []
    var mainSetlistStub: Setlist?
    var recommendedConcertListStub: [Concert] = []
    var errorStub: ConcertError?
    
    var fetchAllConcertListCallCount: Int = 0
    var fetchConcertScheduleListCallCount: Int = 0
    var fetchHomeConcertSectionListCallCount: Int = 0
    var fetchMainSetlistCallCount: Int = 0
    var fetchRecommendedConcertListCallCount: Int = 0
    
    func fetchAllConcertList(startDate: Date?, concertID: Int?) async throws(ConcertError) -> [Concert] {
        fetchAllConcertListCallCount += 1
        if let error = errorStub {
            throw error
        }
        return concertListStub
    }
    
    func fetchConcertArtistInfo(concertID: Int) async throws(ConcertError) -> Artist {
        if let error = errorStub {
            throw error
        }
        guard let artist = artistStub else {
            throw ConcertError.serverError
        }
        return artist
    }
    
    func fetchConcertSetlistList(concertID: Int) async throws(ConcertError) -> [Setlist] {
        if let error = errorStub {
            throw error
        }
        return setlistListStub
    }
    
    func fetchConcertMerchandiseList(concertID: Int) async throws(ConcertError) -> [ConcertMerchandise] {
        if let error = errorStub {
            throw error
        }
        return merchandiseListStub
    }
    
    func fetchConcertInfoList(concertID: Int) async throws(ConcertError) -> [ConcertInfo] {
        if let error = errorStub {
            throw error
        }
        return infoListStub
    }
    
    func fetchConcertCultureList(concertID: Int) async throws(ConcertError) -> [ConcertCulture] {
        if let error = errorStub {
            throw error
        }
        return cultureListStub
    }
    
    func fetchConcertScheduleList(concertID: Int) async throws(ConcertError) -> [ConcertSchedule] {
        fetchConcertScheduleListCallCount += 1
        if let error = errorStub {
            throw error
        }
        return scheduleListStub
    }
    
    func fetchConcert(concertID: Int) async throws(ConcertError) -> Concert {
        if let error = errorStub {
            throw error
        }
        guard let concert = concertStub else {
            throw ConcertError.serverError
        }
        return concert
    }
    
    func fetchSearchConcertSectionList() async throws(ConcertError) -> [ConcertSection] {
        if let error = errorStub {
            throw error
        }
        return searchSectionListStub
    }
    
    func fetchHomeConcertSectionList() async throws(ConcertError) -> [ConcertSection] {
        fetchHomeConcertSectionListCallCount += 1
        if let error = errorStub {
            throw error
        }
        return homeSectionListStub
    }
    
    func fetchMainSetlist(concertID: Int) async throws(ConcertError) -> Setlist? {
        fetchMainSetlistCallCount += 1
        if let error = errorStub {
            throw error
        }
        return mainSetlistStub
    }
    
    func fetchRecommendedConcertList() async throws(ConcertError) -> [Concert] {
        fetchRecommendedConcertListCallCount += 1
        if let error = errorStub {
            throw error
        }
        return recommendedConcertListStub
    }
}
