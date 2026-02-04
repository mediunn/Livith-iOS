//
//  UpdateUserPreferredGenreList.swift
//  LivithNetwork
//
//  Created by 김진웅 on 2/4/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

// MARK: - 42. 유저 취향 장르 설정/변경

public extension DTO.Request {
    struct UpdateUserPreferredGenreList: Encodable {
        public let genreIDs: [Int]
        
        public init(genreIDs: [Int]) {
            self.genreIDs = genreIDs
        }
        
        enum CodingKeys: String, CodingKey {
            case genreIDs = "genreIds"
        }
    }
}

public extension DTO.Response {
    /// API 명세상 조회 API와 동일한 응답
    typealias UpdateUserPreferredGenreList = FetchUserPreferredGenreList
}
