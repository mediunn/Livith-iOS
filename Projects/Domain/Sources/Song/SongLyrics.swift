//
//  SongLyrics.swift
//  Domain
//
//  Created by 김진웅 on 1/21/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

public struct SongLyrics: Identifiable, Hashable {
    public let id: Int
    public let title: String
    public let artist: String
    public let lyrics: [String]
    public let pronunciation: [String]
    public let translation: [String]
    public let youtubeID: String?

    public init(
        id: Int,
        title: String,
        artist: String,
        lyrics: [String],
        pronunciation: [String],
        translation: [String],
        youtubeID: String?
    ) {
        self.id = id
        self.title = title
        self.artist = artist
        self.lyrics = lyrics
        self.pronunciation = pronunciation
        self.translation = translation
        self.youtubeID = youtubeID
    }
}
