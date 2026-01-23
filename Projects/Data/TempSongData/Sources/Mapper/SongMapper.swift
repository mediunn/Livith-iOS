//
//  SongMapper.swift
//  Data
//
//  Created by 김진웅 on 1/21/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

import Domain
import LivithNetwork

struct SongMapper {
    func toDomain(from response: DTO.Response.FetchSongLyrics) -> SongLyrics {
        SongLyrics(
            id: response.id,
            title: response.title,
            artist: response.artist,
            lyrics: response.lyrics,
            pronunciation: response.pronunciation,
            translation: response.translation,
            youtubeID: response.youtubeID
        )
    }
    
    func toDomain(from response: DTO.Response.FetchSongFanchant) -> SongFanchant {
        SongFanchant(
            id: response.id,
            setlistID: response.setlistID,
            songID: response.songID,
            fanchant: response.fanchant,
            fanchantPoint: response.fanchantPoint
        )
    }
}
