//
//  MockUserRepository.swift
//  UserData
//
//  Created by Youjin Lee on 2/6/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

import Domain

#if DEBUG
public struct MockUserRepository: UserRepository {
    public init() {}

    public func updateNickname(_ nickname: String) async throws(UserError) {}

    public func fetchUser() async throws(UserError) -> User {
        User(
            id: 1,
            provider: "kakao",
            providerID: "12345",
            email: "test@test.com",
            nickname: "테스트유저",
            hasPreferences: false,
            authority: UserAuthority(deviceNotification: true, marketingConsent: true)
        )
    }

    @discardableResult
    public func refreshUser() async throws(UserError) -> User {
        try await fetchUser()
    }

    public func fetchInterestedConcert() async throws(UserError) -> Concert? {
        nil
    }

    public func fetchInterestedConcertList(query: InterestConcertListQuery) async throws(UserError) -> InterestConcertPage {
        InterestConcertPage(concertList: [], nextCursor: nil)
    }

    @discardableResult
    public func updateInterestedConcert(_ concertID: Int) async throws(UserError) -> Concert {
        throw UserError.unknown
    }

    public func deleteInterestedConcert() async throws(UserError) {}
}
#endif
