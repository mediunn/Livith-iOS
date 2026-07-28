//
//  PreferenceMapper.swift
//  PreferenceData
//
//  Created by 김진웅 on 2/4/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

import Domain
import LivithNetworking

struct PreferenceMapper {
    func toDomain(from dto: DTO.Response.FetchGenreList) -> [PreferredGenre] {
        dto.compactMap { genre -> PreferredGenre? in
            guard let imageURL = URL(string: genre.imageURLString) else { return nil }
            return PreferredGenre(
                id: genre.id,
                name: genre.name,
                imageURL: imageURL
            )
        }
    }
    
    func toDomain(from dto: DTO.Response.SearchArtistList) -> ArtistSearchResult {
        let artists = dto.data.map { artist in
            PreferredArtist(
                id: artist.id,
                name: artist.name,
                genreID: artist.genreId,
                imageURL: artist.imageURLString.flatMap { URL(string: $0) }
            )
        }
        return ArtistSearchResult(
            artists: artists,
            cursor: dto.cursor,
            totalCount: dto.totalCount
        )
    }
    
    func toDomain(from dto: DTO.Response.FetchUserPreferredGenreList) -> [PreferredGenre] {
        dto.map { genre -> PreferredGenre in
            return PreferredGenre(
                id: genre.id,
                name: genre.name,
                imageURL: genre.imageURLString.flatMap { URL(string: $0) }
            )
        }
    }
    
    func toDomain(from dto: DTO.Response.FetchUserPreferredArtistList) -> [PreferredArtist] {
        dto.map { artist in
            PreferredArtist(
                id: artist.id,
                name: artist.name,
                genreID: artist.genreID,
                imageURL: artist.imageURLString.flatMap { URL(string: $0) }
            )
        }
    }
    
    func toDomain(from dto: DTO.Response.UpdateUserPreferredArtistList) -> [PreferredArtist] {
        dto.map { artist in
            PreferredArtist(
                id: artist.id,
                name: artist.name,
                genreID: artist.genreID,
                imageURL: artist.imageURLString.flatMap { URL(string: $0) }
            )
        }
    }
}
