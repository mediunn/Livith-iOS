//
//  PreferenceRepositoryImpl.swift
//  PreferenceData
//
//  Created by 김진웅 on 2/4/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

import Domain
import LivithNetworking

struct PreferenceRepositoryImpl: PreferenceRepository {
    private let networkClient: NetworkClient
    private let mapper: PreferenceMapper = .init()
    private let errorMapper: PreferenceErrorMapper = .init()
    
    init(networkClient: NetworkClient) {
        self.networkClient = networkClient
    }
    
    func fetchGenreList() async throws(PreferenceError) -> [PreferredGenre] {
        do {
            let response: DTO.Response.FetchGenreList = try await networkClient.request(
                PreferenceAPI.fetchGenreList()
            )
            return mapper.toDomain(from: response)
        } catch {
            throw errorMapper.mapToPreferenceError(error)
        }
    }
    
    func searchArtistList(
        keyword: String?,
        size: Int?,
        cursor: String?
    ) async throws(PreferenceError) -> ArtistSearchResult {
        do {
            let response: DTO.Response.SearchArtistList = try await networkClient.request(
                PreferenceAPI.searchArtistList(keyword: keyword, size: size, cursor: cursor)
            )
            return mapper.toDomain(from: response)
        } catch {
            throw errorMapper.mapToPreferenceError(error)
        }
    }
    
    func fetchUserPreferredGenreList() async throws(PreferenceError) -> [PreferredGenre] {
        do {
            let response: DTO.Response.FetchUserPreferredGenreList = try await networkClient.request(
                PreferenceAPI.fetchUserPreferredGenreList()
            )
            return mapper.toDomain(from: response)
        } catch {
            throw errorMapper.mapToPreferenceError(error)
        }
    }
    
    func fetchUserPreferredArtistList() async throws(PreferenceError) -> [PreferredArtist] {
        do {
            let response: DTO.Response.FetchUserPreferredArtistList = try await networkClient.request(
                PreferenceAPI.fetchUserPreferredArtistList()
            )
            return mapper.toDomain(from: response)
        } catch {
            throw errorMapper.mapToPreferenceError(error)
        }
    }
    
    @discardableResult
    func updateUserPreferredGenreList(genreIDs: [Int]) async throws(PreferenceError) -> [PreferredGenre] {
        do {
            let response: DTO.Response.UpdateUserPreferredGenreList = try await networkClient.request(
                PreferenceAPI.updateUserPreferredGenreList(genreIDs: genreIDs)
            )
            return mapper.toDomain(from: response)
        } catch {
            throw errorMapper.mapToPreferenceError(error)
        }
    }
    
    @discardableResult
    func updateUserPreferredArtistList(artistIDs: [Int]) async throws(PreferenceError) -> [PreferredArtist] {
        do {
            let response: DTO.Response.UpdateUserPreferredArtistList = try await networkClient.request(
                PreferenceAPI.updateUserPreferredArtistList(artistIDs: artistIDs)
            )
            return mapper.toDomain(from: response)
        } catch {
            throw errorMapper.mapToPreferenceError(error)
        }
    }
}
