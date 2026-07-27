//
//  CalendarMonthChangedMessageParser.swift
//  HomeFeature
//
//  Created by 김진웅 on 7/24/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

import LivithFoundation

enum CalendarMonthChangedMessageParser {
    static func dateRange(from body: Any) -> (startDate: String, endDate: String)? {
        guard let dictionary = CalendarWebScriptMessageBodyParser.dictionary(from: body),
              let startDateString = dictionary["startDate"] as? String,
              let endDateString = dictionary["endDate"] as? String,
              isDashDateString(startDateString),
              isDashDateString(endDateString),
              DateFormatterService.date(from: startDateString, type: .dashDate) != nil,
              DateFormatterService.date(from: endDateString, type: .dashDate) != nil
        else {
            return nil
        }
        return (startDateString, endDateString)
    }
}

// MARK: - Private

private extension CalendarMonthChangedMessageParser {
    static func isDashDateString(_ value: String) -> Bool {
        value.range(of: #"^\d{4}-\d{2}-\d{2}$"#, options: .regularExpression) != nil
    }
}
