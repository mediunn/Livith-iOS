//
//  UpdateUserInterestConcert.swift
//  network
//
//  Created by Youjin Lee on 10/14/25.
//  Copyright © 2025 Livith. All rights reserved.
//

// MARK: - 유저의 관심 콘서트 목록 업데이트 (PUT)

import Foundation

public extension DTO.Request {
    struct UpdateInterestedConcerts: Encodable {
        public let concertIDList: [Int]

        public init(concertIDList: [Int]) {
            self.concertIDList = concertIDList
        }

        enum CodingKeys: String, CodingKey {
            case concertIDList = "concertIds"
        }
    }
}
