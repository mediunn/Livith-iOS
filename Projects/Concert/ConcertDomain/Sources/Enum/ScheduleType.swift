//
//  ScheduleType.swift
//  ConcertDomain
//
//  Created by Youjin Lee on 12/27/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import Foundation

public enum ScheduleType: String, CaseIterable, Codable {
    case ticketing = "TICKETING"
    case none = "NONE"
}
