//
//  InterestConcertEntryAlerts.swift
//  LivithNetworking
//
//  Created by 김진웅 on 7/22/26.
//  Copyright © 2026 Livith. All rights reserved.
//

// MARK: - 관심 콘서트 결과 알림(entry-alerts) 목록 조회

import Foundation

public extension DTO.Response {
    struct FetchInterestConcertEntryAlerts: Decodable {
        public let items: [AlertItem]

        public struct AlertItem: Decodable {
            public let kind: String
            public let title: String
            public let content: String
            public let concertId: Int?
        }
    }
}
