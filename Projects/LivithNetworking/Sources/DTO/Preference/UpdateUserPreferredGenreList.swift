//
//  UpdateUserPreferredGenreList.swift
//  LivithNetworking
//
//  Created by 김진웅 on 5/27/26.
//  Copyright © 2026 Livith. All rights reserved.
//

// MARK: - 42. 유저 취향 장르 설정/변경

import Foundation

public extension DTO.Request {
    struct UpdateUserPreferredGenreList: Encodable {
        public let genreIDList: [Int]

        public init(genreIDs: [Int]) {
            self.genreIDList = genreIDs
        }

        enum CodingKeys: String, CodingKey {
            case genreIDList = "genreIds"
        }
    }
}

public extension DTO.Response {
    typealias UpdateUserPreferredGenreList = FetchUserPreferredGenreList
}
