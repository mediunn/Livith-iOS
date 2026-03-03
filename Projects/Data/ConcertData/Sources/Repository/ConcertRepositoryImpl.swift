//
//  ConcertRepositoryImpl.swift
//  Data
//
//  Created by 김진웅 on 1/22/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

import Domain
import LivithNetwork
import LivithFoundation

struct ConcertRepositoryImpl: ConcertRepository {
    private let homeService: HomeService
    private let searchService: SearchService
    private let concertService: ConcertService
    private let setlistService: SetlistService
    private let mapper: ConcertMapper = .init()
    private let errorMapper: ConcertErrorMapper = .init()
    
    init(
        homeService: HomeService,
        searchService: SearchService,
        concertService: ConcertService,
        setlistService: SetlistService
    ) {
        self.homeService = homeService
        self.searchService = searchService
        self.concertService = concertService
        self.setlistService = setlistService
    }
    
    func fetchAllConcertList(startDate: Date?, concertID: Int?) async throws(ConcertError) -> [Concert] {
        let cursor: String? = configureCursor(startDate: startDate)

        do {
            let response: DTO.Response.FetchConcertList = try await searchService.request(
                .fetchConcertList(cursor: cursor, size: 12, id: concertID)
            )
            return mapper.toDomain(from: response)
        } catch {
            throw errorMapper.mapToConcertError(error)
        }
    }
    
    func fetchConcertArtistInfo(concertID: Int) async throws(ConcertError) -> Artist {
        do {
            let response: DTO.Response.FetchConcertArtistInfo = try await concertService.request(
                .fetchConcertArtistInfo(concertID: concertID)
            )
            return mapper.toDomain(from: response)
        } catch {
            throw errorMapper.mapToConcertError(error)
        }
    }
    
    func fetchConcertSetlistList(concertID: Int) async throws(ConcertError) -> [Setlist] {
        do {
            let response: DTO.Response.FetchConcertSetlistList = try await concertService.request(
                .fetchConcertSetlistList(concertID: concertID)
            )
            return mapper.toDomain(from: response)
        } catch {
            throw errorMapper.mapToConcertError(error)
        }
    }
    
    func fetchConcertMerchandiseList(concertID: Int) async throws(ConcertError) -> [ConcertMerchandise] {
        do {
            let response: DTO.Response.FetchConcertMerchandiseList = try await concertService.request(
                .fetchConcertMerchandiseList(concertID: concertID)
            )
            return mapper.toDomain(from: response)
        } catch {
            throw errorMapper.mapToConcertError(error)
        }
    }
    
    func fetchConcertInfoList(concertID: Int) async throws(ConcertError) -> [ConcertInfo] {
        do {
            let response: DTO.Response.FetchConcertInfoList = try await concertService.request(
                .fetchConcertInfoList(concertID: concertID)
            )
            return mapper.toDomain(from: response)
        } catch {
            throw errorMapper.mapToConcertError(error)
        }
    }
    
    func fetchConcertCultureList(concertID: Int) async throws(ConcertError) -> [ConcertCulture] {
        do {
            let response: DTO.Response.FetchConcertCultureList = try await concertService.request(
                .fetchConcertCultureList(concertID: concertID)
            )
            return mapper.toDomain(from: response)
        } catch {
            throw errorMapper.mapToConcertError(error)
        }
    }
    
    func fetchConcertScheduleList(concertID: Int) async throws(ConcertError) -> [ConcertSchedule] {
        do {
            let response: DTO.Response.FetchConcertSchedule = try await concertService.request(
                .fetchConcertSchedule(concertID: concertID)
            )
            return mapper.toDomain(from: response)
        } catch {
            throw errorMapper.mapToConcertError(error)
        }
    }
    
    func fetchConcert(concertID: Int) async throws(ConcertError) -> Concert {
        do {
            let response: DTO.Response.FetchConcertInfo = try await concertService.request(
                .fetchConcertInfo(concertID: concertID)
            )
            
            guard let concert = mapper.toDomain(from: response) else {
                throw ConcertError.invalidResponse
            }
            
            return concert
        } catch {
            throw errorMapper.mapToConcertError(error)
        }
    }
    
    func fetchSearchConcertSectionList() async throws(ConcertError) -> [ConcertSection] {
        do {
            let response: DTO.Response.FetchSectionList = try await searchService.request(.fetchSections)
            return mapper.toDomain(from: response)
        } catch {
            throw errorMapper.mapToConcertError(error)
        }
    }
    
    func fetchHomeConcertSectionList() async throws(ConcertError) -> [ConcertSection] {
        do {
            let response: DTO.Response.FetchHomeSectionList = try await homeService.request(.fetchSectionList)
            return mapper.toDomain(from: response)
        } catch {
            throw errorMapper.mapToConcertError(error)
        }
    }
    
    func fetchMainSetlist(concertID: Int) async throws(ConcertError) -> Setlist? {
        do {
            let response: DTO.Response.FetchConcertSetlist? = try await setlistService.request(
                .fetchConcertMainSetlist(concertID: concertID)
            )
            guard let response = response else { return nil }
            let setlist: Setlist? = mapper.toDomain(from: response)
            return setlist
        } catch NetworkError.noData {
            return nil
        } catch {
            throw errorMapper.mapToConcertError(error)
        }
    }

    func fetchRecommendedConcertList() async throws(ConcertError) -> [Concert] {
        do {
            let response: DTO.Response.FetchRecommendedConcertList = try await homeService.request(.fetchRecommendedConcertList)
            return mapper.toDomain(from: response)
        } catch {
            throw errorMapper.mapToConcertError(error)
        }
    }
}

// MARK: - Helpers

private extension ConcertRepositoryImpl {
    func configureCursor(startDate: Date?) -> String? {
        guard let startDate else { return nil }
        return DateFormatterService.string(from: startDate, type: .dotDate)
    }
}
