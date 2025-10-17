//
//  FetchSongLyrics.swift
//  network
//
//  Created by Youjin Lee on 10/14/25.
//  Copyright © 2025 Livith. All rights reserved.
//

// MARK: - 18. 특정 노래의 가사 정보 조회(원어, 발음, 해석)

import Foundation

public extension DTO.Response {
    struct FetchSongLyrics: Decodable {
        public let id: Int
        public let title: String
        public let artist: String
        public let lyrics: [String]
        public let pronunciation: [String]
        public let translation: [String]
        public let youtubeID: String

        enum CodingKeys: String, CodingKey {
            case id
            case title
            case artist
            case lyrics
            case pronunciation
            case translation
            case youtubeID = "youtubeId"
        }
    }
}
