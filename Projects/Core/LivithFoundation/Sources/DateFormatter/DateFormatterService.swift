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
    private static let lock = NSLock()

    /// String을 Date로 변환합니다.
    public static func date(from string: String, type: DateFormatType) -> Date? {
        lock.lock()
        defer { lock.unlock() }
        return type.formatter.date(from: string)
    }

    /// Date를 String으로 변환합니다.
    public static func string(from date: Date, type: DateFormatType) -> String {
        lock.lock()
        defer { lock.unlock() }
        return type.formatter.string(from: date)
    }
}
