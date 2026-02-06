//
//  ConcertRepository.swift
//  Domain
//
//  Created by 김진웅 on 1/21/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

public protocol ConcertRepository {
    func fetchAllConcertList(startDate: Date?, concertID: Int?) async throws(ConcertError) -> [Concert]
    func fetchConcertArtistInfo(concertID: Int) async throws(ConcertError) -> Artist
    func fetchConcertSetlistList(concertID: Int) async throws(ConcertError) -> [Setlist]
    func fetchConcertMerchandiseList(concertID: Int) async throws(ConcertError) -> [ConcertMerchandise]
    func fetchConcertInfoList(concertID: Int) async throws(ConcertError) -> [ConcertInfo]
    func fetchConcertCultureList(concertID: Int) async throws(ConcertError) -> [ConcertCulture]
    func fetchConcertScheduleList(concertID: Int) async throws(ConcertError) -> [ConcertSchedule]
    func fetchConcert(concertID: Int) async throws(ConcertError) -> Concert
    func fetchSearchConcertSectionList() async throws(ConcertError) -> [ConcertSection]
    func fetchHomeConcertSectionList() async throws(ConcertError) -> [ConcertSection]
    func fetchMainSetlist(concertID: Int) async throws(ConcertError) -> Setlist?
    func fetchRecommendedConcertList() async throws(ConcertError) -> [Concert]
}
