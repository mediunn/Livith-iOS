//
//  UserRepository.swift
//  Domain
//
//  Created by 김진웅 on 1/21/26.
//  Copyright © 2026 Livith. All rights reserved.
//

public protocol UserRepository {
    func updateNickname(_ nickname: String) async throws(UserError)
    func fetchUser() async throws(UserError) -> User
    @discardableResult
    func refreshUser() async throws(UserError) -> User
    func fetchInterestedConcertList(query: InterestConcertListQuery) async throws(UserError) -> InterestConcertPage
    func checkInterestedConcert(id: Int) async throws(UserError) -> Bool
    func updateInterestedConcerts(ids: [Int]) async throws(UserError)
}

public extension UserRepository {
    func fetchInterestedConcert() async throws(UserError) -> Concert? {
        try await fetchInterestedConcertList(query: .init()).concertList.first?.concert
    }
}
