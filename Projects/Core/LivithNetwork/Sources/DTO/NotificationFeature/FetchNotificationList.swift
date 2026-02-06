//
//  FetchNotificationList.swift
//  LivithNetwork
//
//  Created by Youjin Lee on 2/6/26.
//  Copyright © 2026 Livith. All rights reserved.
//

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
