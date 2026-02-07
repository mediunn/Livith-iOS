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
    func fetchInterestedConcert() async throws(UserError) -> Concert?
    @discardableResult
    func updateInterestedConcert(_ concertID: Int) async throws(UserError) -> Concert
    func deleteInterestedConcert() async throws(UserError)
}
