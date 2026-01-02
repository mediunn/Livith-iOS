//
//  HomeRepository.swift
//  HomeDomain
//
//  Created by 김진웅 on 12/29/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import Foundation

public protocol HomeRepository {
    func fetchSectionList() async throws(HomeError) -> HomeSectionList
    func fetchInterestedConcert() async throws(HomeError) -> Concert?
    @discardableResult
    func updateInterestedConcert(id: Int) async throws(HomeError) -> Concert
    func deleteInterestedConcert() async throws(HomeError)
    func fetchRecommendKeywordList(for keyword: String) async throws(HomeError) -> [String]
    func fetchConcertList(startDate: String?, concertID: Int?) async throws(HomeError) -> [Concert]
    func fetchSearchedConcertList(
        keyword: String,
        startDate: String?,
        concertID: Int?
    ) async throws(HomeError) -> [Concert]
    func fetchMainSetlist(for concertID: Int) async throws(HomeError) -> Setlist
    func fetchSongList(for setlistID: Int) async throws(HomeError) -> SetlistSongList
    func fetchScheduleList(for concertID: Int) async throws(HomeError) -> ConcertScheduleList
}
