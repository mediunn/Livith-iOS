//
//  CalendarMonthChangedMessageParser.swift
//  HomeFeature
//
//  Created by 김진웅 on 7/24/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

enum CalendarMonthChangedMessageParser {
    static func yearMonth(from body: Any) -> (year: Int, month: Int)? {
        guard let dictionary = CalendarWebScriptMessageBodyParser.dictionary(from: body),
              let year = CalendarWebScriptMessageBodyParser.intValue(dictionary["year"]),
              let month = CalendarWebScriptMessageBodyParser.intValue(dictionary["month"]),
              (1...12).contains(month)
        else {
            return nil
        }
        return (year, month)
    }
}
