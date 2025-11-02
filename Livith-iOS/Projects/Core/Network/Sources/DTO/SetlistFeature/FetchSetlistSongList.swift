//
//  FetchSetlistSongList.swift
//  network
//
//  Created by Youjin Lee on 10/14/25.
//  Copyright © 2025 Livith. All rights reserved.
//

// MARK: - 4. 특정 셋리스트의 곡 목록 조회

import Foundation

public extension DTO.Response {
    typealias FetchSetlistSongList = [SetlistSong]

    struct SetlistSong: Decodable {
        public let id: Int
        public let title: String
        public let artist: String
        public let orderIndex: Int
    }
}
