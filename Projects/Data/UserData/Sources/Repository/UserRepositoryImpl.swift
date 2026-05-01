//
//  UserRepositoryImpl.swift
//  Data
//
//  Created by 김진웅 on 2026/01/22.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

import Domain
import LivithFoundation
import LivithNetwork
import Persistence

struct UserRepositoryImpl: UserRepository {
    private let onboardingService: OnboardingService
    private let homeService: HomeService
    private let userService: UserService
    private let userCache: UserDiskCache
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

    func fetchInterestedConcertList(query: InterestConcertListQuery) async throws(UserError) -> InterestConcertPage {
        do {
            let request = makeFetchInterestConcertListRequest(from: query)
            let response: DTO.Response.FetchUserInterestConcert = try await homeService.request(
                .fetchInterestedConcertList(request)
            )
            return mapper.toDomain(from: response)
        } catch NetworkError.noData {
            return InterestConcertPage(concertList: [], nextCursor: nil)
        } catch {
            let userError: UserError = errorMapper.mapToUserError(error)
            throw userError
        }
    }

    func checkInterestedConcert(id: Int) async throws(UserError) -> Bool {
        do {
            let response: DTO.Response.CheckInterestedConcert = try await homeService.request(
                .checkInterestedConcert(concertID: id)
            )
            return response.isInterested
        } catch {
            let userError: UserError = errorMapper.mapToUserError(error)
            throw userError
        }
    }

    func updateInterestedConcerts(ids: [Int]) async throws(UserError) {
        do {
            let request = DTO.Request.UpdateInterestedConcerts(concertIDList: ids)
            let _: DTO.Response.EmptyResponse = try await homeService.request(
                .updateInterestedConcerts(request)
            )
        } catch {
            let userError: UserError = errorMapper.mapToUserError(error)
            throw userError
        }
    }
}

// MARK: - Helpers

private extension UserRepositoryImpl {
    func makeFetchInterestConcertListRequest(
        from query: InterestConcertListQuery
    ) -> DTO.Request.FetchInterestConcertList {
        DTO.Request.FetchInterestConcertList(
            sort: makeFetchInterestConcertListSort(from: query.sort),
            size: query.pageSize,
            cursorDate: query.cursor.map { DateFormatterService.string(from: $0.date, type: .dotDate) },
            cursorID: query.cursor?.id
        )
    }

    func makeFetchInterestConcertListSort(
        from sort: InterestConcertSort
    ) -> DTO.Request.FetchInterestConcertList.Sort {
        switch sort {
        case .concert:
            return .concert
        case .ticketing:
            return .ticketing
        }
    }

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
