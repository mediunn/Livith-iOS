//
//  UserRepositoryImpl.swift
//  Data
//
//  Created by 김진웅 on 2026/01/22.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

import Domain
import LivithNetwork
import Persistence

struct UserRepositoryImpl: UserRepository {
    private let onboardingService: OnboardingService
    private let homeService: HomeService
    private let userService: UserService
    private let userCache: UserDiskCache
    private let interestConcertCache: InterestConcertCache
    private let mapper: UserMapper = .init()
    private let errorMapper: UserErrorMapper = .init()

    init(
        onboardingService: OnboardingService,
        homeService: HomeService,
        userService: UserService,
        userdefaultsStorage: UserDefaultsStorage
    ) {
        self.onboardingService = onboardingService
        self.homeService = homeService
        self.userService = userService
        self.userCache = UserDiskCache(userdefaultsStorage: userdefaultsStorage)
        self.interestConcertCache = InterestConcertCache(userdefaultsStorage: userdefaultsStorage)
    }

    func updateNickname(_ nickname: String) async throws(UserError) {
        do {
            let request = DTO.Request.UpdateUserNickname(nickname: nickname)
            let response: DTO.Response.UpdateUserNickname = try await userService.request(
                .updateUserNickname(request: request)
            )
            await userCache.updateUser { user in
                user.nickname = response.nickname
            }
        } catch {
            let userError: UserError = errorMapper.mapToUserError(error)
            throw userError
        }
    }

    func fetchUser() async throws(UserError) -> User {
        if let cachedUser = await userCache.fetchUserIfValid() {
            return cachedUser
        }
        return try await fetchUserFromNetwork()
    }

    @discardableResult
    func refreshUser() async throws(UserError) -> User {
        try await fetchUserFromNetwork()
    }

    func fetchInterestedConcert() async throws(UserError) -> Concert? {
        if let cachedConcert = await interestConcertCache.fetchInterestConcertIfValid() {
            return cachedConcert
        }

        do {
            let response: DTO.Response.FetchUserInterestConcert? = try await homeService.request(.fetchInterestedConcert)
            guard let response else { return nil }
            guard let concert = mapper.toDomain(from: response) else {
                throw UserError.invalidResponse
            }
            await interestConcertCache.saveInterestConcert(concert)
            return concert
        } catch NetworkError.noData {
            return nil
        } catch {
            let userError: UserError = errorMapper.mapToUserError(error)
            throw userError
        }
    }

    @discardableResult
    func updateInterestedConcert(_ concertID: Int) async throws(UserError) -> Concert {
        do {
            let response: DTO.Response.UpdateUserInterestConcert = try await homeService.request(
                .updateInterestedConcert(id: concertID)
            )
            guard let concert = mapper.toDomain(from: response) else {
                throw UserError.invalidResponse
            }
            await interestConcertCache.saveInterestConcert(concert)
            return concert
        } catch {
            let userError: UserError = errorMapper.mapToUserError(error)
            throw userError
        }
    }

    func deleteInterestedConcert() async throws(UserError) {
        do {
            let _: DTO.Response.EmptyResponse = try await homeService.request(.deleteInterestedConcert)
            await interestConcertCache.deleteInterestConcert()
        } catch {
            let userError: UserError = errorMapper.mapToUserError(error)
            throw userError
        }
    }
}

// MARK: - Helpers

private extension UserRepositoryImpl {
    func fetchUserFromNetwork() async throws(UserError) -> User {
        do {
            let response: DTO.Response.FetchUserInfo = try await onboardingService.request(.fetchUserInfo)
            let user: User = mapper.toDomain(from: response)
            await userCache.saveUser(user)
            return user
        } catch {
            let userError: UserError = errorMapper.mapToUserError(error)
            throw userError
        }
    }
}
