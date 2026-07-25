//
//  CalendarFilter.swift
//  Domain
//
//  Created by 김진웅 on 7/23/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

// MARK: - Schedule Type Filter

public enum CalendarScheduleTypeFilter: String, Sendable {
    case ticketing = "TICKETING"
    case concert = "CONCERT"
}

// MARK: - Concert Type Filter

public enum CalendarConcertTypeFilter: String, Sendable {
    case all = "ALL"
    case interest = "INTEREST"
}
