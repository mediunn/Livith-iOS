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
    var interestConcertListStub: [InterestConcert] = []
    var interestConcertPageStub: InterestConcertPage?
    var interestConcertPageByCursorID: [Int: InterestConcertPage] = [:]
    var interestConcertPageResultQueue: [Result<InterestConcertPage, UserError>] = []
    var fetchInterestedConcertListDelayQueue: [UInt64] = []
    var updatedConcertStub: Concert?
    var updatedConcertListStub: [Concert] = []
    var errorStub: UserError?
    var fetchUserErrorStub: UserError?
    var fetchInterestedConcertListErrorStub: UserError?
    
    var fetchUserCallCount: Int = 0
    var fetchInterestedConcertListCallCount: Int = 0
    var fetchInterestedConcertListQuery: InterestConcertListQuery?
    var fetchInterestedConcertListQueryList: [InterestConcertListQuery] = []
    var updateInterestedConcertCallCount: Int = 0
    var updateInterestedConcertListCallCount: Int = 0
    var updateInterestedConcertIDList: [Int]?
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
    
    func fetchInterestedConcertList(query: InterestConcertListQuery) async throws(UserError) -> InterestConcertPage {
        let (delay, queuedResult) = await MainActor.run {
            fetchInterestedConcertListCallCount += 1
            fetchInterestedConcertListQuery = query
            fetchInterestedConcertListQueryList.append(query)

            let delay: UInt64
            if !fetchInterestedConcertListDelayQueue.isEmpty {
                delay = fetchInterestedConcertListDelayQueue.removeFirst()
            } else {
                delay = 0
            }

            let queuedResult: Result<InterestConcertPage, UserError>?
            if !interestConcertPageResultQueue.isEmpty {
                queuedResult = interestConcertPageResultQueue.removeFirst()
            } else {
                queuedResult = nil
            }

            return (delay, queuedResult)
        }

        if delay > 0 {
            try? await Task.sleep(nanoseconds: delay)
        }

        if let queuedResult {
            switch queuedResult {
            case .success(let page):
                return page
            case .failure(let error):
                throw error
            }
        }

        let fallbackResult: Result<InterestConcertPage, UserError> = await MainActor.run {
            if let error = fetchInterestedConcertListErrorStub {
                return .failure(error)
            }
            if let error = errorStub {
                return .failure(error)
            }

            if let cursorID = query.cursor?.id,
               let cursorPage = interestConcertPageByCursorID[cursorID] {
                return .success(cursorPage)
            }

            if let interestConcertPageStub {
                return .success(interestConcertPageStub)
            }

            return .success(InterestConcertPage(concertList: interestConcertListStub, nextCursor: nil))
        }

        switch fallbackResult {
        case .success(let page):
            return page
        case .failure(let error):
            throw error
        }
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

    @discardableResult
    func updateInterestedConcertList(_ concertIDList: [Int]) async throws(UserError) -> [Concert] {
        updateInterestedConcertListCallCount += 1
        updateInterestedConcertIDList = concertIDList
        if let error = errorStub {
            throw error
        }
        return updatedConcertListStub
    }
    
    func deleteInterestedConcert() async throws(UserError) {
        deleteInterestedConcertCallCount += 1
        if let error = errorStub {
            throw error
        }
    }
}
