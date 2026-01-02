//
//  SetlistSong.swift
//  HomeDomain
//
//  Created by 김진웅 on 12/29/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import Foundation

public typealias SetlistSongList = [SetlistSong]

public struct SetlistSong: Identifiable, Hashable {
    public let id: Int
    public let title: String
    public let artist: String
    public let orderIndex: Int

    public init(
        id: Int,
        title: String,
        artist: String,
        orderIndex: Int
    ) {
        self.id = id
        self.title = title
        self.artist = artist
        self.orderIndex = orderIndex
    }
}
