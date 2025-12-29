//
//  ConcertSchedule.swift
//  Concert
//
//  Created by Youjin Lee on 12/27/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import Foundation

public struct ConcertSchedule: Identifiable, Hashable {
    public let id: Int
    public let category: String
    public let scheduledAt: Date
    public let type: ScheduleType

    public init(
        id: Int,
        category: String,
        scheduledAt: Date,
        type: ScheduleType
    ) {
        self.id = id
        self.category = category
        self.scheduledAt = scheduledAt
        self.type = type
    }
}
