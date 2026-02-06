//
//  NotificationItem.swift
//  Domain
//
//  Created by Youjin Lee on 2/6/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

public struct NotificationItem: Identifiable, Equatable {
    public let id: Int
    public let type: NotificationType
    public let title: String
    public let content: String
    public let targetID: Int?
    public var isRead: Bool
    public let createdAt: Date

    public init(
        id: Int,
        type: NotificationType,
        title: String,
        content: String,
        targetID: Int?,
        isRead: Bool,
        createdAt: Date
    ) {
        self.id = id
        self.type = type
        self.title = title
        self.content = content
        self.targetID = targetID
        self.isRead = isRead
        self.createdAt = createdAt
    }

    public var displayCreatedAt: String {
        let now = Date()
        let interval = now.timeIntervalSince(createdAt)
        let hours = Int(interval / 3600)
        let days = Int(interval / 86400)

        if hours < 24 {
            return "\(max(1, hours))시간 전"
        } else if days < 7 {
            return "\(days)일 전"
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy.MM.dd"
            formatter.locale = Locale(identifier: "ko_KR")
            return formatter.string(from: createdAt)
        }
    }
}
