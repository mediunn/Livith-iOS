//
//  ConcertSchedule.swift
//  Domain
//
//  Created by 김진웅 on 1/21/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

public struct ConcertSchedule: Hashable, Identifiable {
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

public enum ScheduleType: String, CaseIterable, Hashable {
    case preTicketing = "PRE_TICKETING"
    case generalTicketing = "GENERAL_TICKETING"
    case concert = "CONCERT"
    case none = "NONE"

    public init(value: String) {
        self = .init(rawValue: value.uppercased()) ?? .none
    }
}
