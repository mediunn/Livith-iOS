//
//  ConcertRepository.swift
//  Domain
//
//  Created by 김진웅 on 1/21/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

public protocol ConcertRepository {
    func fetchConcertInfo(concertID: Int) async throws(ConcertError) -> Concert
    func fetchConcertSchedule(concertID: Int) async throws(ConcertError) -> [ConcertSchedule]
    func fetchConcertCultureList(concertID: Int) async throws(ConcertError) -> [ConcertCulture]
    func fetchConcertInfoList(concertID: Int) async throws(ConcertError) -> [ConcertInfo]
    func fetchConcertMerchandiseList(concertID: Int) async throws(ConcertError) -> [ConcertMerchandise]
    func fetchConcertSetlistList(concertID: Int) async throws(ConcertError) -> [Setlist]
    func fetchConcertArtistInfo(concertID: Int) async throws(ConcertError) -> Artist
    func setInterestConcert(concertID: Int) async throws(ConcertError)
}
