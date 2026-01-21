//
//  SetlistMapper.swift
//  Data
//
//  Created by 김진웅 on 1/21/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

import Domain
import LivithNetwork
import LivithFoundation

struct SetlistMapper {
    func toDomain(from response: DTO.Response.FetchConcertSetlist) -> Setlist {
        Setlist(
            id: response.id,
            title: response.title,
            imageURL: response.imageURL,
            type: SetlistType(rawValue: response.type.lowercased()) ?? .original,
            status: response.status,
            startDate: DateFormatterService.date(from: response.startDate, type: .dotDate) ?? Date(),
            endDate: DateFormatterService.date(from: response.endDate, type: .dotDate) ?? Date(),
            venue: response.venue,
            artist: response.artist
        )
    }
    
    func toDomain(from response: DTO.Response.FetchSetlistSongList) -> [SetlistSong] {
        response.map { dto in
            SetlistSong(
                id: dto.id,
                title: dto.title,
                artist: dto.artist,
                orderIndex: dto.orderIndex
            )
        }
    }
}
