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
        userdefaultsStorage: UserDefaultsStorage,
        widgetImageStorage: WidgetImageStorage
    ) {
        self.onboardingService = onboardingService
        self.homeService = homeService
        self.userService = userService
        self.userCache = UserDiskCache(userdefaultsStorage: userdefaultsStorage)
        self.interestConcertCache = InterestConcertCache(userdefaultsStorage: userdefaultsStorage, widgetImageStorage: widgetImageStorage)
    }
    
    func updateNickname(_ nickname: String) async throws(UserError) {
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
    
    func fetchUser() async throws(UserError) -> User {
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
            await userCache.updateUser { $0.interestConcertID = concert.id }
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
            await userCache.updateUser { $0.interestConcertID = concert.id }
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
            await userCache.updateUser { $0.interestConcertID = nil }
            await interestConcertCache.deleteInterestConcert()
        } catch {
            let userError: UserError = errorMapper.mapToUserError(error)
            throw userError
        }
    }

    func updateNotificationConsent(
        field: NotificationConsentField,
        isAgreed: Bool
    ) async throws(UserError) -> NotificationConsentResult {
        do {
            let request = DTO.Request.UpdateNotificationConsent(
                field: field.rawValue,
                isAgreed: isAgreed
            )
            let response: DTO.Response.UpdateNotificationConsent = try await userService.request(
                .updateNotificationConsent(request: request)
            )
            return mapper.toDomain(from: response)
        } catch {
            let userError: UserError = errorMapper.mapToUserError(error)
            throw userError
        }
    }

    func fetchNotificationSettings() async throws(UserError) -> NotificationSettings {
        do {
            let response: DTO.Response.FetchNotificationSettings = try await userService.request(
                .fetchNotificationSettings
            )
            return mapper.toDomain(from: response)
        } catch {
            let userError: UserError = errorMapper.mapToUserError(error)
            throw userError
        }
    }

    func updateMarketingConsent() async throws(UserError) -> NotificationConsentResult {
        do {
            let response: DTO.Response.UpdateNotificationConsent = try await userService.request(
                .updateMarketingConsent
            )
            return mapper.toDomain(from: response)
        } catch {
            let userError: UserError = errorMapper.mapToUserError(error)
            throw userError
        }
    }

    func fetchNotificationList(cursor: Int?, size: Int) async throws(UserError) -> [NotificationItem] {
        do {
            let response: [DTO.Response.FetchNotificationList] = try await userService.request(
                .fetchNotificationList(cursor: cursor, size: size)
            )
            return response.map { mapper.toDomain(from: $0) }
        } catch {
            let userError: UserError = errorMapper.mapToUserError(error)
            throw userError
        }
    }

    func markNotificationAsRead(id: Int) async throws(UserError) {
        do {
            let _: DTO.Response.EmptyResponse = try await userService.request(
                .markNotificationAsRead(id: id)
            )
        } catch {
            let userError: UserError = errorMapper.mapToUserError(error)
            throw userError
        }
    }
}
