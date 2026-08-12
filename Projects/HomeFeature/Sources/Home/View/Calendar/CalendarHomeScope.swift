//
//  CalendarHomeScope.swift
//  HomeFeature
//
//  Created by 김진웅 on 7/19/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

struct CalendarHomeScope {
    let state: CalendarHomeState
    let send: (CalendarHomeIntent) -> DiscardableTask
}
