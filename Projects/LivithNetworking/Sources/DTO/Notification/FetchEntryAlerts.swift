//
//  FetchEntryAlerts.swift
//  LivithNetworking
//
//  Created by Youjin Lee on 7/24/26.
//  Copyright © 2026 Livith. All rights reserved.
//

// MARK: - 64. 관심 콘서트 결과 알림(토스트) 목록

import Foundation

public extension DTO.Response {
    struct FetchEntryAlerts: Decodable {
        public let items: [EntryAlertItem]
    }

    struct EntryAlertItem: Decodable {
        public let kind: String
        public let title: String
        public let content: String
        public let concertID: Int?

        enum CodingKeys: String, CodingKey {
            case kind, title, content
            case concertID = "concertId"
        }
    }
}
