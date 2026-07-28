//
//  FetchNotificationList.swift
//  LivithNetworking
//
//  Created by 김진웅 on 5/27/26.
//  Copyright © 2026 Livith. All rights reserved.
//

// MARK: - 47. 알림 목록 조회

import Foundation

public extension DTO.Response {
    struct FetchNotificationList: Decodable {
        public let id: Int
        public let type: String
        public let title: String
        public let content: String
        public let targetID: String?
        public let isRead: Bool
        public let createdAt: String

        enum CodingKeys: String, CodingKey {
            case id, type, title, content, isRead, createdAt
            case targetID = "targetId"
        }
    }
}
