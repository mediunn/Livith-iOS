//
//  HomeRepositoryImpl.swift
//  HomeData
//
//  Created by 김진웅 on 12/29/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import Foundation

import HomeDomain
import LivithNetwork

struct HomeRepositoryImpl {
    private let homeService: HomeService
    private let mapper: HomeMapper = .init()
    private let errorMapper: HomeErrorMapper = .init()
    
    init(homeService: HomeService) {
        self.homeService = homeService
    }
}

extension HomeRepositoryImpl: HomeRepository {
    func fetchSectionList() async throws(HomeError) -> HomeSectionList {
        do {
            let response: DTO.Response.FetchHomeSectionList = try await homeService.request(.fetchSectionList)
            return mapper.toDomain(from: response)
        } catch {
            printError(error)
            throw errorMapper.mapToDomainError(from: error)
        }
    }

    func fetchInterestedConcert() async throws(HomeError) -> Concert? {
        do {
            let response: DTO.Response.FetchUserInterestConcert = try await homeService.request(.fetchInterestedConcert)
            return mapper.toDomain(from: response)
        } catch NetworkError.decodingFailed {
            return nil
        } catch {
            printError(error)
            throw errorMapper.mapToDomainError(from: error)
        }
    }

    @discardableResult
    func updateInterestedConcert(id: Int) async throws(HomeError) -> Concert {
        do {
            let response: DTO.Response.UpdateUserInterestConcert = try await homeService.request(
                .updateInterestedConcert(id: id)
            )
            guard let concert = mapper.toDomain(from: response) else {
                throw HomeError.unknown
            }
            return concert
        } catch {
            printError(error)
            throw errorMapper.mapToDomainError(from: error)
        }
    }

    func deleteInterestedConcert() async throws(HomeError) {
        do {
            let _: DTO.Response.EmptyResponse = try await homeService.request(.deleteInterestedConcert)
        } catch {
            printError(error)
            throw errorMapper.mapToDomainError(from: error)
        }
    }
}

// MARK: - Helpers

private extension HomeRepositoryImpl {
    func printError(_ error: Error) {
        #if DEBUG
        print("[HomeRepository] Error: \(error) \(error.localizedDescription)")
        #endif
    }
}
