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
    public let isRead: Bool
    public let createdAt: String

    public init(
        id: Int,
        type: NotificationType,
        title: String,
        content: String,
        targetID: Int?,
        isRead: Bool,
        createdAt: String
    ) {
        self.id = id
        self.type = type
        self.title = title
        self.content = content
        self.targetID = targetID
        self.isRead = isRead
        self.createdAt = createdAt
    }
}
