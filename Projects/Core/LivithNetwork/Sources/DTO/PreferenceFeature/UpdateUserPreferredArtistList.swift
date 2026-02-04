//
//  UpdateUserPreferredArtistList.swift
//  LivithNetwork
//
//  Created by 김진웅 on 2/4/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

// MARK: - 43. 유저 취향 아티스트 설정/변경

public extension DTO.Request {
    struct UpdateUserPreferredArtistList: Encodable {
        public let artistIDs: [Int]
        
        public init(artistIDs: [Int]) {
            self.artistIDs = artistIDs
        }
        
        enum CodingKeys: String, CodingKey {
            case artistIDs = "artistIds"
        }
    }
}

public extension DTO.Response {
    /// API 명세상 조회 API와 동일한 응답
    typealias UpdateUserPreferredArtistList = FetchUserPreferredArtistList
}
