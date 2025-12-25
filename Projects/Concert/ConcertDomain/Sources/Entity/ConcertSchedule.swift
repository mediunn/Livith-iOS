//
//  ConcertSchedule.swift
//  Concert
//
//  Created by Youjin Lee on 12/27/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import Foundation

import ConcertDomain

struct ConcertSchedule: Identifiable, Hashable {
    public let id: Int
    public let category: String
    public let scheduledAt: Date
    public let type: ScheduleType
}
