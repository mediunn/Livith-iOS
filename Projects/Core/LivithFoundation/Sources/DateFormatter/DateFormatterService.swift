//
//  DateFormatterService.swift
//  LivithFoundation
//
//  Created by Youjin Lee on 1/4/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

// MARK: - DateFormatterService

public enum DateFormatterService {
    /// String을 Date로 변환합니다.
    public static func date(from string: String, type: DateFormatType) -> Date? {
        type.formatter.date(from: string)
    }

    /// Date를 String으로 변환합니다.
    public static func string(from date: Date, type: DateFormatType) -> String {
        type.formatter.string(from: date)
    }
}
