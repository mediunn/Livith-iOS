//
//  FetchSetlistSongList.swift
//  LivithNetworking
//
//  Created by 김진웅 on 5/27/26.
//  Copyright © 2026 Livith. All rights reserved.
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
