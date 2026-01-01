//
//  SongItem.swift
//  HomeFeature
//
//  Created by 김진웅 on 1/1/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

typealias SongList = [SongItem]

struct SongItem: Identifiable, Hashable {
    let id: Int
    let title: String
    let artist: String
    let orderIndex: Int
}

extension SongList {
    static let sample: SongList = [
        SongItem(id: 1, title: "첫 번째 노래", artist: "아티스트 A", orderIndex: 1),
        SongItem(id: 2, title: "두 번째 노래", artist: "아티스트 B", orderIndex: 2),
        SongItem(id: 3, title: "세 번째 노래", artist: "아티스트 C", orderIndex: 3),
        SongItem(id: 4, title: "네 번째 노래", artist: "아티스트 D", orderIndex: 4),
        SongItem(id: 5, title: "다섯 번째 노래", artist: "아티스트 E", orderIndex: 5)
    ]
}