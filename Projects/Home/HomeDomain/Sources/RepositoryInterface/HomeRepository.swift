//
//  HomeRepository.swift
//  HomeDomain
//
//  Created by 김진웅 on 12/29/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import Foundation

public protocol HomeRepository {
    func fetchSectionList() async throws(HomeError) -> [ConcertSection]
    func fetchInterestedConcert() async throws(HomeError) -> Concert?
    @discardableResult
    func updateInterestedConcert(id: Int) async throws(HomeError) -> Concert
    func deleteInterestedConcert() async throws(HomeError)
}
