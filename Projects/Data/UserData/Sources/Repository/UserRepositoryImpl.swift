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
import LivithNetworking
import Persistence

struct UserRepositoryImpl: UserRepository {
    private let networkClient: NetworkClient
    private let userCache: UserDiskCache
    private let mapper: UserMapper = .init()
    private let errorMapper: UserErrorMapper = .init()

    init(
        networkClient: NetworkClient,
        userdefaultsStorage: UserDefaultsStorage
    ) {
        self.networkClient = networkClient
        self.userCache = UserDiskCache(userdefaultsStorage: userdefaultsStorage)
    }

    func updateNickname(_ nickname: String) async throws(UserError) {
        do {
            let response: DTO.Response.UpdateUserNickname = try await networkClient.request(
                UserAPI.updateNickname(nickname)
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

    func fetchInterestedConcertList(filter: InterestConcertListFilter) async throws(UserError) -> ListResult<InterestConcert> {
        do {
            let request = try makeFetchInterestConcertListRequest(from: filter)
            let response: DTO.Response.FetchUserInterestConcert = try await networkClient.request(
                HomeAPI.fetchInterestedConcertList(
                    sort: request.sort?.rawValue,
                    size: request.size,
                    cursorDate: request.cursorDate,
                    cursorID: request.cursorID
                )
            )
            return mapper.toDomain(from: response)
        } catch NetworkError.noData {
            return ListResult(items: [], nextToken: nil)
        } catch let error as UserError {
            throw error
        } catch {
            let userError: UserError = errorMapper.mapToUserError(error)
            throw userError
        }
    }

    func checkInterestedConcert(id: Int) async throws(UserError) -> Bool {
        do {
            let response: DTO.Response.CheckInterestedConcert = try await networkClient.request(
                HomeAPI.checkInterestedConcert(concertID: id)
            )
            return response.isInterested
        } catch {
            let userError: UserError = errorMapper.mapToUserError(error)
            throw userError
        }
    }

    @discardableResult
    func updateInterestedConcert(_ concertID: Int) async throws(UserError) -> Concert {
        do {
            let response: DTO.Response.UpdateUserInterestConcert = try await networkClient.request(
                HomeAPI.updateInterestedConcert(concertID: concertID)
            )
            guard let concert = mapper.toDomain(from: response) else {
                throw UserError.invalidResponse
            }
            return concert
        } catch let error as UserError {
            throw error
        } catch {
            let userError: UserError = errorMapper.mapToUserError(error)
            throw userError
        }
    }

    @discardableResult
    func updateInterestedConcertList(_ concertIDList: [Int]) async throws(UserError) -> [Concert] {
        do {
            let response: DTO.Response.UpdateUserInterestConcertList = try await networkClient.request(
                HomeAPI.updateInterestedConcertList(concertIDList: concertIDList)
            )
            return mapper.toDomain(from: response)
        } catch NetworkError.noData {
            return []
        } catch {
            let userError: UserError = errorMapper.mapToUserError(error)
            throw userError
        }
    }

    func deleteInterestedConcert() async throws(UserError) {
        do {
            try await networkClient.request(
                HomeAPI.deleteInterestedConcert()
            )
        } catch {
            let userError: UserError = errorMapper.mapToUserError(error)
            throw userError
        }
    }

    func fetchInterestConcertCleanupPolicy() async throws(UserError) -> InterestConcertCleanupPolicy {
        do {
            let response: DTO.Response.FetchInterestConcertToast = try await networkClient.request(
                HomeAPI.fetchInterestConcertToast()
            )
            guard let policy = mapper.toDomain(from: response) else {
                throw UserError.invalidResponse
            }

            return policy
        } catch let error as UserError {
            throw error
        } catch {
            let userError: UserError = errorMapper.mapToUserError(error)
            throw userError
        }
    }

    func markInterestConcertToastShown() async throws(UserError) {
        do {
            let _: DTO.Response.UpdateInterestConcertToast = try await networkClient.request(
                HomeAPI.markInterestConcertToastShown()
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
        from filter: InterestConcertListFilter
    ) throws(UserError) -> DTO.Request.FetchInterestConcertList {
        let nextToken = try makeInterestConcertListNextToken(from: filter.nextToken)

        return DTO.Request.FetchInterestConcertList(
            sort: filter.sort.map(makeFetchInterestConcertListSort),
            size: filter.limit,
            cursorDate: nextToken?.cursorDate,
            cursorID: nextToken?.id
        )
    }

    func makeInterestConcertListNextToken(
        from nextToken: (any NextToken)?
    ) throws(UserError) -> InterestConcertListNextToken? {
        guard let nextToken else { return nil }
        guard let interestConcertListNextToken = nextToken as? InterestConcertListNextToken else {
            throw UserError.invalidRequest
        }

        return interestConcertListNextToken
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
            let response: DTO.Response.FetchUserInfo = try await networkClient.request(
                OnboardingAPI.fetchUserInfo()
            )
            let user: User = mapper.toDomain(from: response)
            await userCache.saveUser(user)
            return user
        } catch {
            let userError: UserError = errorMapper.mapToUserError(error)
            throw userError
        }
    }
}
