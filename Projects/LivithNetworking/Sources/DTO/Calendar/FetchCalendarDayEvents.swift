//
//  FetchCalendarDayEvents.swift
//  LivithNetworking
//
//  Created by 김진웅 on 7/23/26.
//  Copyright © 2026 Livith. All rights reserved.
//

// MARK: - 62. 날짜별 일정 조회

import Foundation

public extension DTO.Response {
    struct FetchCalendarDayEvents: Decodable {
        public let date: String
        public let events: [Event]

        public struct Event: Decodable {
            public let id: Int
            public let title: String?
            public let type: String
            public let status: String
            public let time: String?
            public let detail: String?
        }
    }
}
