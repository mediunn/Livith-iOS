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

public struct UserRepositoryImpl: UserRepository {
    private let onboardingService: OnboardingService
    private let homeService: HomeService
    private let userService: UserService
    private let userCache: UserDiskCache
    private let interestConcertCache: InterestConcertCache
    private let mapper: UserMapper = .init()
    private let errorMapper: UserErrorMapper = .init()
    
    public init(
        onboardingService: OnboardingService,
        homeService: HomeService,
        userService: UserService,
        userdefaultsStorage: UserDefaultsStorage,
        widgetImageStorage: WidgetImageStorage
    ) {
        self.onboardingService = onboardingService
        self.homeService = homeService
        self.userService = userService
        self.userCache = UserDiskCache(userdefaultsStorage: userdefaultsStorage)
        self.interestConcertCache = InterestConcertCache(userdefaultsStorage: userdefaultsStorage, widgetImageStorage: widgetImageStorage)
    }

    public func updateNickname(_ nickname: String) async throws(UserError) {
        do {
            let request = DTO.Request.UpdateUserNickname(nickname: nickname)
            let response: DTO.Response.UpdateUserNickname = try await userService.request(
                .updateUserNickname(request: request)
            )
            let user: User = mapper.toDomain(from: response)
            await userCache.saveUser(user)
        } catch {
            let userError: UserError = errorMapper.mapToUserError(error)
            throw userError
        }
    }

    public func fetchUser() async throws(UserError) -> User {
        if let cachedUser = await userCache.fetchUserIfValid() {
            return cachedUser
        }
        
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

    public func fetchInterestedConcert() async throws(UserError) -> Concert? {
        if let cachedConcert = await interestConcertCache.fetchInterestConcertIfValid() {
            return cachedConcert
        }
        
        do {
            let response: DTO.Response.FetchUserInterestConcert? = try await homeService.request(.fetchInterestedConcert)
            guard let response else { return nil }
            guard let concert = mapper.toDomain(from: response) else {
                throw UserError.invalidResponse
            }
            await userCache.updateUser { $0.interestConcertID = concert.id }
            await interestConcertCache.saveInterestConcert(concert)
            return concert
        } catch {
            let userError: UserError = errorMapper.mapToUserError(error)
            throw userError
        }
    }

    @discardableResult
    public func updateInterestedConcert(_ concertID: Int) async throws(UserError) -> Concert {
        do {
            let response: DTO.Response.UpdateUserInterestConcert = try await homeService.request(
                .updateInterestedConcert(id: concertID)
            )
            guard let concert = mapper.toDomain(from: response) else {
                throw UserError.invalidResponse
            }
            await userCache.updateUser { $0.interestConcertID = concert.id }
            await interestConcertCache.saveInterestConcert(concert)
            return concert
        } catch {
            let userError: UserError = errorMapper.mapToUserError(error)
            throw userError
        }
    }

    public func deleteInterestedConcert() async throws(UserError) {
        do {
            let _: DTO.Response.EmptyResponse = try await homeService.request(.deleteInterestedConcert)
            await userCache.updateUser { $0.interestConcertID = nil }
            await interestConcertCache.deleteInterestConcert()
        } catch {
            let userError: UserError = errorMapper.mapToUserError(error)
            throw userError 
        }
    }
}
