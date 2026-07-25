//
//  CalendarDateSelectedMessageParser.swift
//  HomeFeature
//
//  Created by 김진웅 on 7/24/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

import LivithFoundation

enum CalendarDateSelectedMessageParser {

    static func date(from body: Any) -> Date? {
        guard let dateString = dateString(from: body) else {
            return nil
        }
        return DateFormatterService.date(from: dateString, type: .dashDate)
    }
}

// MARK: - Private

private extension CalendarDateSelectedMessageParser {
    static func dateString(from body: Any) -> String? {
        if let dictionary = CalendarWebScriptMessageBodyParser.dictionary(from: body) {
            return dictionary["date"] as? String
        }

        if let string = body as? String {
            return string
        }

        return nil
    }
}
