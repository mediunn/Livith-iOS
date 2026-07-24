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
        guard let dictionary = dictionary(from: body),
              let year = intValue(dictionary["year"]),
              let month = intValue(dictionary["month"]),
              (1...12).contains(month)
        else {
            return nil
        }
        return (year, month)
    }
}

// MARK: - Private

private extension CalendarMonthChangedMessageParser {
    static func dictionary(from body: Any) -> [String: Any]? {
        if let dictionary = body as? [String: Any] {
            return dictionary
        }
        if let dictionary = body as? NSDictionary {
            return dictionary as? [String: Any]
        }
        if let string = body as? String,
           let data = string.data(using: .utf8),
           let dictionary = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
            return dictionary
        }
        return nil
    }

    static func intValue(_ value: Any?) -> Int? {
        if let int = value as? Int {
            return int
        }
        if let number = value as? NSNumber {
            return number.intValue
        }
        return nil
    }
}
