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
import Persistence

struct HomeRepositoryImpl {
    private let homeService: HomeService
    private let searchService: SearchService
    private let setlistService: SetlistService
    private let concertService: ConcertService
    private let localStorage: UserDefaultsStorage
    private let mapper: HomeMapper = .init()
    private let errorMapper: HomeErrorMapper = .init()
    
    init(
        homeService: HomeService,
        searchService: SearchService,
        setlistService: SetlistService,
        concertService: ConcertService,
        localStorage: UserDefaultsStorage
    ) {
        self.homeService = homeService
        self.searchService = searchService
        self.setlistService = setlistService
        self.concertService = concertService
        self.localStorage = localStorage
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
            let response: DTO.Response.FetchUserInterestConcert? = try await homeService.request(.fetchInterestedConcert)
            
            guard let response else {
                return nil
            }
            
            return mapper.toDomain(from: response)
        } catch NetworkError.decodingFailed, NetworkError.noData {
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
            
            updateInterestedConcertLocally(id: concert.id)
            return concert
        } catch {
            printError(error)
            throw errorMapper.mapToDomainError(from: error)
        }
    }
    
    func deleteInterestedConcert() async throws(HomeError) {
        do {
            let _: DTO.Response.EmptyResponse = try await homeService.request(.deleteInterestedConcert)
            deleteInterestedConcertLocally()
        } catch NetworkError.noData {
            return
        } catch {
            printError(error)
            throw errorMapper.mapToDomainError(from: error)
        }
    }
    
    func fetchRecommendKeywordList(for keyword: String) async throws(HomeError) -> [String] {
        do {
            let response: DTO.Response.FetchRecommendKeywordList = try await searchService.request(
                .fetchRecommendedSearchResult(letter: keyword)
            )
            return response
        } catch {
            printError(error)
            throw errorMapper.mapToDomainError(from: error)
        }
    }
    
    func fetchConcertList(startDate: String?, concertID: Int?) async throws(HomeError) -> [Concert] {
        do {
            let response: DTO.Response.FetchConcertList = try await searchService.request(
                .fetchConcertList(
                    startDate: startDate,
                    concertID: concertID,
                    size: 12
                )
            )
            return mapper.toDomain(from: response)
        } catch {
            printError(error)
            throw errorMapper.mapToDomainError(from: error)
        }
    }
    
    func fetchSearchedConcertList(
        keyword: String,
        startDate: String?,
        concertID: Int?
    ) async throws(HomeError) -> [Concert] {
        let cursor: String? = if let startDate = startDate, let concertID = concertID {
            "{\"value\":\"\(startDate)\",\"id\":\(concertID)}"
        } else {
            nil
        }
        
        do {
            let response: DTO.Response.FetchFilterSearchResult = try await searchService.request(
                .fetchFilterSearchResult(
                    genre: [],
                    sort: "LATEST",
                    status: [],
                    keyword: keyword,
                    cursor: cursor,
                    size: 12
                )
            )
            return mapper.toDomain(from: response)
        } catch {
            printError(error)
            throw errorMapper.mapToDomainError(from: error)
        }
    }
    
    func fetchMainSetlist(for concertID: Int) async throws(HomeError) -> Setlist? {
        do {
            let response: DTO.Response.FetchConcertSetlist = try await setlistService.request(
                .fetchConcertMainSetlist(concertID: concertID)
            )
            return mapper.toDomain(from: response)
        } catch NetworkError.noData {
            return nil
        } catch {
            printError(error)
            throw errorMapper.mapToDomainError(from: error)
        }
    }
    
    func fetchSongList(for setlistID: Int) async throws(HomeError) -> SetlistSongList {
        do {
            let response: DTO.Response.FetchSetlistSongList = try await setlistService.request(
                .fetchSetlistSongList(setlistID: setlistID)
            )
            return mapper.toDomain(from: response)
        } catch {
            printError(error)
            throw errorMapper.mapToDomainError(from: error)
        }
    }
    
    func fetchScheduleList(for concertID: Int) async throws(HomeError) -> ConcertScheduleList {
        do {
            let response: DTO.Response.FetchConcertSchedule = try await concertService.request(
                .fetchConcertSchedule(concertID: concertID)
            )
            return mapper.toDomain(from: response)
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
    
    func updateInterestedConcertLocally(id: Int) {
        do {
            let currentUser: DTO.Response.FetchUserInfo = try localStorage.fetch(for: Keys.currentUser)
            let updatedUser = DTO.Response.FetchUserInfo(
                id: currentUser.id,
                interestConcertID: id,
                provider: currentUser.provider,
                providerID: currentUser.providerID,
                email: currentUser.email,
                nickname: currentUser.nickname,
                marketingConsent: currentUser.marketingConsent
            )
            try localStorage.save(updatedUser, for: Keys.currentUser)
        } catch {
            printError(error)
        }
    }

    func deleteInterestedConcertLocally() {
        do {
            let currentUser: DTO.Response.FetchUserInfo = try localStorage.fetch(for: Keys.currentUser)
            let updatedUser = DTO.Response.FetchUserInfo(
                id: currentUser.id,
                interestConcertID: nil,
                provider: currentUser.provider,
                providerID: currentUser.providerID,
                email: currentUser.email,
                nickname: currentUser.nickname,
                marketingConsent: currentUser.marketingConsent
            )
            try localStorage.save(updatedUser, for: Keys.currentUser)
        } catch {
            printError(error)
        }
    }
}

// MARK: - Keys

private extension HomeRepositoryImpl {
    enum Keys {
        static let currentUser = "currentUser"
    }
}
