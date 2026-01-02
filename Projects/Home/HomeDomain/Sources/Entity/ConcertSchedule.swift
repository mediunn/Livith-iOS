//
//  ConcertSchedule.swift
//  HomeDomain
//
//  Created by 김진웅 on 12/29/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import Foundation

public typealias ConcertScheduleList = [ConcertSchedule]

public struct ConcertSchedule: Identifiable, Hashable {
    public let id: Int
    public let category: String
    public let schduledAt: Date
    
    public init(
        id: Int,
        category: String,
        schduledAt: Date
    ) {
        self.id = id
        self.category = category
        self.schduledAt = schduledAt
    }
}
