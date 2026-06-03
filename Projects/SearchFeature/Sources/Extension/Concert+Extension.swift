//
//  Concert+Extension.swift
//  SearchFeature
//
//  Created by Youjin Lee on 1/24/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

import DisplaySupport
import Domain

extension Concert {
    var formattedStartDate: String {
        ConcertDisplayHelper.dateRange(for: self)
    }
}
