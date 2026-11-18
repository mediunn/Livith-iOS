//
//  ArtistSearchResult.swift
//  Domain
//
//  Created by 김진웅 on 2/4/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

public struct ArtistSearchResult {
    public let artists: [PreferredArtist]
    public let cursor: Int?
    public let totalCount: Int?
    
    public init(
        artists: [PreferredArtist],
        cursor: Int?,
        totalCount: Int?
    ) {
        self.artists = artists
        self.cursor = cursor
        self.totalCount = totalCount
    }
}
