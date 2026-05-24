//
//  FetchSongFanchant.swift
//  LivithNetworking
//
//  Created by 김진웅 on 5/24/26.
//  Copyright © 2026 Livith. All rights reserved.
//

// MARK: - 19. 특정 셋리스트의 곡 응원법, 응원법 포인트 조회

import Foundation

public extension DTO.Response {
    struct FetchSongFanchant: Decodable {
        public let id: Int
        public let setlistID: Int
        public let songID: Int
        public let fanchant: [String]
        public let fanchantPoint: String?

        enum CodingKeys: String, CodingKey {
            case id
            case setlistID = "setlistId"
            case songID = "songId"
            case fanchant
            case fanchantPoint
        }
    }
}
