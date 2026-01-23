//
//  Concert+Extension.swift
//  SearchFeature
//
//  Created by Youjin Lee on 1/24/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

import Domain

extension Concert {
    var formattedStartDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd"
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter.string(from: startDate)
    }
}
