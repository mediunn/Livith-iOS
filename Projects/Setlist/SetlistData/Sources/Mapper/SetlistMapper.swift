//
//  SetlistMapper.swift
//  SetlistData
//
//  Created by Youjin Lee on 12/30/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import Foundation

import LivithNetwork
import SetlistDomain

struct SetlistMapper {
    private let dateFormatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withFullDate]
        return formatter
    }()

    func toDomain(from response: DTO.Response.FetchConcertSetlist) -> Setlist? {
        guard let startDate = dateFormatter.date(from: response.startDate),
              let endDate = dateFormatter.date(from: response.endDate) else {
            return nil
        }

        let type: SetlistType
        switch response.type.uppercased() {
        case "EXPECTED":
            type = .expected
        case "RECENT":
            type = .recent
        case "PAST":
            type = .past
        default:
            type = .none
        }

        return Setlist(
            id: response.id,
            title: response.title,
            imageURL: response.imageURL,
            type: type,
            status: response.status,
            startDate: startDate,
            endDate: endDate,
            venue: response.venue,
            artist: response.artist
        )
    }

    func toDomain(from response: DTO.Response.FetchSetlistSongList) -> [SetlistSong] {
        return response.map { song in
            SetlistSong(
                id: song.id,
                title: song.title,
                artist: song.artist,
                orderIndex: song.orderIndex
            )
        }
    }
}
