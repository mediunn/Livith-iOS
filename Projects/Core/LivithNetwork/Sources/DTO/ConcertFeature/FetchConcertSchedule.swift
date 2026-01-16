//
//  FetchConcertSchedule.swift
//  network
//
//  Created by Youjin Lee on 10/14/25.
//  Copyright © 2025 Livith. All rights reserved.
//

// MARK: - 2. 특정 콘서트 일정 목록 조회

import Foundation

public extension DTO.Response {
    typealias FetchConcertSchedule = [ConcertSchedule]

    struct ConcertSchedule: Codable {
        public let id: Int
        public let category: String
        public let scheduledAt: String
        public let type: String?
    }
}
