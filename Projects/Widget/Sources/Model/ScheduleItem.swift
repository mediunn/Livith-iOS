//
//  ScheduleItem.swift
//  LivithWidget
//
//  Created by Youjin Lee on 1/15/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

struct ScheduleItem: Identifiable {
    let id: Int
    let category: String
    let scheduledAt: String
    let dDay: Int

    var formattedDDay: String {
        if dDay > 0 {
            return "D-\(dDay)"
        } else if dDay == 0 {
            return "D-Day"
        } else {
            return "D+\(abs(dDay))"
        }
    }
}
