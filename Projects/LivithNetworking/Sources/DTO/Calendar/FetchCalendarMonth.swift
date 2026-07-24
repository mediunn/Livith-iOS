//
//  FetchCalendarMonth.swift
//  LivithNetworking
//
//  Created by 김진웅 on 7/23/26.
//  Copyright © 2026 Livith. All rights reserved.
//

// MARK: - 61. 월별 캘린더 조회

import Foundation

public extension DTO.Response {
    struct FetchCalendarMonth: Decodable {
        public let year: Int
        public let month: Int
        public let days: [Day]

        public struct Day: Decodable {
            public let date: String
            public let events: [Event]
        }

        public struct Event: Decodable {
            public let id: Int
            public let artist: String
            public let type: String
        }
    }
}
