//
//  ConcertRepositoryImpl.swift
//  Data
//
//  Created by 김진웅 on 1/22/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

import Domain
import LivithNetworking
import LivithFoundation

struct ConcertRepositoryImpl: ConcertRepository {
    private let homeService: any HomeService
    private let searchService: any SearchService
    private let concertService: any ConcertService
    private let setlistService: any SetlistService
    private let mapper: ConcertMapper = .init()
    private let errorMapper: ConcertErrorMapper = .init()
    
    init(
        homeService: any HomeService,
        searchService: any SearchService,
        concertService: any ConcertService,
        setlistService: any SetlistService
    ) {
        self.homeService = homeService
        self.searchService = searchService
        self.concertService = concertService
        self.setlistService = setlistService
    }
    
    func fetchAllConcertList(startDate: Date?, concertID: Int?) async throws(ConcertError) -> [Concert] {
        let nextToken = concertID.map { ConcertListNextToken(cursor: $0) }
        return try await fetchAllConcertList(after: nextToken, size: 12).items
    }

    func fetchAllConcertList(after nextToken: (any NextToken)?, size: Int) async throws(ConcertError) -> ListResult<Concert> {
        let cursor = try makeCursor(from: nextToken)

        do {
            let response: DTO.Response.FetchConcertList = try await searchService.fetchConcertList(cursor: cursor, size: size)
            return mapper.toConcertListResult(from: response)
        } catch {
            throw errorMapper.mapToConcertError(error)
        }
    }
    
    func fetchConcertArtistInfo(concertID: Int) async throws(ConcertError) -> Artist {
        do {
            let response: DTO.Response.FetchConcertArtistInfo = try await concertService.fetchConcertArtistInfo(concertID: concertID)
            return mapper.toDomain(from: response)
        } catch {
            throw errorMapper.mapToConcertError(error)
        }
    }
    
    func fetchConcertSetlistList(concertID: Int) async throws(ConcertError) -> [Setlist] {
        do {
            let response: DTO.Response.FetchConcertSetlistList = try await concertService.fetchConcertSetlistList(concertID: concertID)
            return mapper.toDomain(from: response)
        } catch {
            throw errorMapper.mapToConcertError(error)
        }
    }
    
    func fetchConcertMerchandiseList(concertID: Int) async throws(ConcertError) -> [ConcertMerchandise] {
        do {
            let response: DTO.Response.FetchConcertMerchandiseList = try await concertService.fetchConcertMerchandiseList(concertID: concertID)
            return mapper.toDomain(from: response)
        } catch {
            throw errorMapper.mapToConcertError(error)
        }
    }
    
    func fetchConcertInfoList(concertID: Int) async throws(ConcertError) -> [ConcertInfo] {
        do {
            let response: DTO.Response.FetchConcertInfoList = try await concertService.fetchConcertInfoList(concertID: concertID)
            return mapper.toDomain(from: response)
        } catch {
            throw errorMapper.mapToConcertError(error)
        }
    }
    
    func fetchConcertCultureList(concertID: Int) async throws(ConcertError) -> [ConcertCulture] {
        do {
            let response: DTO.Response.FetchConcertCultureList = try await concertService.fetchConcertCultureList(concertID: concertID)
            return mapper.toDomain(from: response)
        } catch {
            throw errorMapper.mapToConcertError(error)
        }
    }
    
    func fetchConcertScheduleList(concertID: Int) async throws(ConcertError) -> [ConcertSchedule] {
        do {
            let response: DTO.Response.FetchConcertSchedule = try await concertService.fetchConcertSchedule(concertID: concertID)
            return mapper.toDomain(from: response)
        } catch {
            throw errorMapper.mapToConcertError(error)
        }
    }
    
    func fetchConcert(concertID: Int) async throws(ConcertError) -> Concert {
        do {
            let response: DTO.Response.FetchConcertInfo = try await concertService.fetchConcertInfo(concertID: concertID)
            
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
            let response: DTO.Response.FetchSectionList = try await searchService.fetchSections()
            return mapper.toDomain(from: response)
        } catch {
            throw errorMapper.mapToConcertError(error)
        }
    }
    
    func fetchHomeConcertSectionList() async throws(ConcertError) -> [ConcertSection] {
        do {
            let response: DTO.Response.FetchHomeSectionList = try await homeService.fetchSectionList()
            return mapper.toDomain(from: response)
        } catch {
            throw errorMapper.mapToConcertError(error)
        }
    }
    
    func fetchMainSetlist(concertID: Int) async throws(ConcertError) -> Setlist? {
        do {
            let response: DTO.Response.FetchConcertSetlist? = try await setlistService.fetchConcertMainSetlist(concertID: concertID)
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
            let response: DTO.Response.FetchRecommendedConcertList = try await homeService.fetchRecommendedConcertList()
            return mapper.toDomain(from: response)
        } catch {
            throw errorMapper.mapToConcertError(error)
        }
    }
}

// MARK: - Helpers

private extension ConcertRepositoryImpl {
    func makeCursor(from nextToken: (any NextToken)?) throws(ConcertError) -> Int? {
        guard let nextToken else { return nil }
        guard let concertListNextToken = nextToken as? ConcertListNextToken else {
            throw ConcertError.invalidRequest
        }

        return concertListNextToken.cursor
    }
}
