//
//  ConcertRepository.swift
//  ConcertDomain
//
//  Created by Youjin Lee on 12/25/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import Foundation

public protocol ConcertRepository {
    func fetchConcertInfo(concertID: Int) async throws(ConcertError) -> Concert
    func fetchConcertSchedule(concertID: Int) async throws(ConcertError) -> [ConcertSchedule]
    func fetchConcertCultureList(concertID: Int) async throws(ConcertError) -> [ConcertCulture]
    func fetchConcertInfoList(concertID: Int) async throws(ConcertError) -> [ConcertInfo]
    func fetchConcertMerchandiseList(concertID: Int) async throws(ConcertError) -> [ConcertMerchandise]
    func fetchConcertSetlistList(concertID: Int) async throws(ConcertError) -> [ConcertSetlist]
    func fetchConcertArtistInfo(concertID: Int) async throws(ConcertError) -> Artist
    func setInterestConcert(concertID: Int) async throws(ConcertError)
}
