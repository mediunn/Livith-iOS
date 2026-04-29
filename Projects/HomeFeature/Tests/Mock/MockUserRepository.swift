//
//  MockUserRepository.swift
//  HomeFeatureTests
//
//  Created by 김진웅 on 2/5/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

import Domain

final class MockUserRepository: UserRepository {
    var userStub: User?
    var interestedConcertStub: Concert?
    var interestConcertPageStub: InterestConcertPage = .init(concertList: [], nextCursor: nil)
    var updatedConcertStub: Concert?
    var errorStub: UserError?
    var fetchUserErrorStub: UserError?
    var fetchInterestedConcertListErrorStub: UserError?
    
    var fetchUserCallCount: Int = 0
    var fetchInterestedConcertCallCount: Int = 0
    var fetchInterestedConcertListCallCount: Int = 0
    var updateInterestedConcertCallCount: Int = 0
    var deleteInterestedConcertCallCount: Int = 0
    var updateNicknameCallCount: Int = 0
    
    func updateNickname(_ nickname: String) async throws(UserError) {
        updateNicknameCallCount += 1
        if let error = errorStub {
            throw error
        }
    }
    
    func fetchUser() async throws(UserError) -> User {
        fetchUserCallCount += 1
        if let error = fetchUserErrorStub {
            throw error
        }
        if let error = errorStub {
            throw error
        }
        guard let user = userStub else {
            throw UserError.serverError
        }
        return user
    }
    
    func refreshUser() async throws(UserError) -> User {
        fetchUserCallCount += 1
        if let error = errorStub {
            throw error
        }
        guard let user = userStub else {
            throw UserError.serverError
        }
        return user
    }
    
    func fetchInterestedConcert() async throws(UserError) -> Concert? {
        fetchInterestedConcertCallCount += 1
        if let error = errorStub {
            throw error
        }
        return interestedConcertStub
    }

    func fetchInterestedConcertList(query: InterestConcertListQuery) async throws(UserError) -> InterestConcertPage {
        fetchInterestedConcertListCallCount += 1
        if let error = fetchInterestedConcertListErrorStub {
            throw error
        }
        if let error = errorStub {
            throw error
        }
        return interestConcertPageStub
    }
    
    @discardableResult
    func updateInterestedConcert(_ concertID: Int) async throws(UserError) -> Concert {
        updateInterestedConcertCallCount += 1
        if let error = errorStub {
            throw error
        }
        guard let concert = updatedConcertStub else {
            throw UserError.serverError
        }
        return concert
    }
    
    func deleteInterestedConcert() async throws(UserError) {
        deleteInterestedConcertCallCount += 1
        if let error = errorStub {
            throw error
        }
    }
}
