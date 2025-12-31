//
//  ConcertRepositoryImpl.swift
//  ConcertData
//
//  Created by Youjin Lee on 12/25/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import Foundation

import ConcertDomain
import LivithNetwork

public struct ConcertRepositoryImpl {
    private let service: ConcertService
    private let entityMapper: ConcertMapper = .init()
    private let errorMapper: ConcertErrorMapper = .init()

    public init(service: ConcertService = .init()) {
        self.service = service
    }
}

extension ConcertRepositoryImpl: ConcertRepository {
    public func fetchConcertInfo(concertID: Int) async throws(ConcertError) -> Concert {
        do {
            let response: DTO.Response.FetchConcertInfo = try await service.request(
                .fetchConcertInfo(concertID: concertID)
            )
            guard let concert = entityMapper.toDomain(from: response) else {
                throw ConcertError.invalidResponse
            }
            return concert
        } catch let error as ConcertError {
            throw error
        } catch {
            throw errorMapper.mapToConcertError(error)
        }
    }

    public func fetchConcertSchedule(concertID: Int) async throws(ConcertError) -> [ConcertSchedule] {
        do {
            let response: DTO.Response.FetchConcertSchedule = try await service.request(
                .fetchConcertSchedule(concertID: concertID)
            )
            return entityMapper.toDomain(from: response)
        } catch {
            throw errorMapper.mapToConcertError(error)
        }
    }

    public func fetchConcertCultureList(concertID: Int) async throws(ConcertError) -> [ConcertCulture] {
        do {
            let response: DTO.Response.FetchConcertCultureList = try await service.request(
                .fetchConcertCultureList(concertID: concertID)
            )
            return entityMapper.toDomain(from: response)
        } catch {
            throw errorMapper.mapToConcertError(error)
        }
    }

    public func fetchConcertInfoList(concertID: Int) async throws(ConcertError) -> [ConcertInfo] {
        do {
            let response: DTO.Response.FetchConcertInfoList = try await service.request(
                .fetchConcertInfoList(concertID: concertID)
            )
            return entityMapper.toDomain(from: response)
        } catch {
            throw errorMapper.mapToConcertError(error)
        }
    }

    public func fetchConcertMerchandiseList(concertID: Int) async throws(ConcertError) -> [ConcertMerchandise] {
        do {
            let response: DTO.Response.FetchConcertMerchandiseList = try await service.request(
                .fetchConcertMerchandiseList(concertID: concertID)
            )
            return entityMapper.toDomain(from: response)
        } catch {
            throw errorMapper.mapToConcertError(error)
        }
    }

    public func fetchConcertSetlistList(concertID: Int) async throws(ConcertError) -> [ConcertSetlist] {
        do {
            let response: DTO.Response.FetchConcertSetlistList = try await service.request(
                .fetchConcertSetlistList(concertID: concertID)
            )
            return entityMapper.toDomain(from: response)
        } catch {
            throw errorMapper.mapToConcertError(error)
        }
    }

    public func fetchConcertArtistInfo(concertID: Int) async throws(ConcertError) -> Artist {
        do {
            let response: DTO.Response.FetchConcertArtistInfo = try await service.request(
                .fetchConcertArtistInfo(concertID: concertID)
            )
            return entityMapper.toDomain(from: response)
        } catch {
            throw errorMapper.mapToConcertError(error)
        }
    }

    public func setInterestConcert(concertID: Int) async throws(ConcertError) {
        do {
            let _: DTO.Response.UpdateUserInterestConcert = try await service.request(
                .setInterestConcert(concertID: concertID)
            )
        } catch {
            throw errorMapper.mapToConcertError(error)
        }
    }
}
