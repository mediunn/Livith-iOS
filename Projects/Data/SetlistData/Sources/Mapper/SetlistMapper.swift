//
//  SetlistMapper.swift
//  Data
//
//  Created by 김진웅 on 1/21/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

import Domain
import LivithNetworking
import LivithFoundation

struct SetlistMapper {
    func toDomain(from response: DTO.Response.FetchConcertSetlist) -> Setlist? {
        guard let startDate = DateFormatterService.date(from: response.startDate, type: .dotDate),
              let endDate = DateFormatterService.date(from: response.endDate, type: .dotDate)
        else {
            return nil
        }
        
        return Setlist(
            id: response.id,
            title: response.title,
            imageURL: response.imageURL.flatMap { URL(string: $0) },
            type: .init(value: response.type),
            status: response.status.flatMap { SetlistStatus(rawValue: $0) },
            startDate: startDate,
            endDate: endDate,
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
