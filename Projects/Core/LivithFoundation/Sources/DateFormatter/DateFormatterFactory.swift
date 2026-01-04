//
//  DateFormatterFactory.swift
//  LivithFoundation
//
//  Created by Youjin Lee on 1/4/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

// MARK: - DateFormatterFactory

public enum DateFormatterFactory {
    private static let lock = NSLock()
}

// MARK: - Private Constants

private extension DateFormatterFactory {
    
    // MARK: - Network 포맷 (en_US_POSIX, Asia/Seoul)

    private static let _iso8601: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(identifier: "Asia/Seoul")
        return formatter
    }()

    private static let _dashDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(identifier: "Asia/Seoul")
        return formatter
    }()

    private static let _dotDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(identifier: "Asia/Seoul")
        return formatter
    }()

    private static let _shortDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM.dd"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(identifier: "Asia/Seoul")
        return formatter
    }()

    // MARK: - Display 포맷 (ko_KR)

    private static let _koreanDateTime: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "M/d(E) h:mma"
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.amSymbol = "AM"
        formatter.pmSymbol = "PM"
        return formatter
    }()

    private static let _koreanDateOnly: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "M/d(E)"
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter
    }()

    private static let _koreanFullDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy년 M월 d일"
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter
    }()
}


// MARK: - Public API (Thread-safe)

public extension DateFormatterFactory {
    enum iso8601 {
        public static func date(from string: String) -> Date? {
            lock.lock()
            defer { lock.unlock() }
            return _iso8601.date(from: string)
        }

        public static func string(from date: Date) -> String {
            lock.lock()
            defer { lock.unlock() }
            return _iso8601.string(from: date)
        }
    }

    enum dashDate {
        public static func date(from string: String) -> Date? {
            lock.lock()
            defer { lock.unlock() }
            return _dashDate.date(from: string)
        }

        public static func string(from date: Date) -> String {
            lock.lock()
            defer { lock.unlock() }
            return _dashDate.string(from: date)
        }
    }

    enum dotDate {
        public static func date(from string: String) -> Date? {
            lock.lock()
            defer { lock.unlock() }
            return _dotDate.date(from: string)
        }

        public static func string(from date: Date) -> String {
            lock.lock()
            defer { lock.unlock() }
            return _dotDate.string(from: date)
        }
    }

    enum shortDate {
        public static func date(from string: String) -> Date? {
            lock.lock()
            defer { lock.unlock() }
            return _shortDate.date(from: string)
        }

        public static func string(from date: Date) -> String {
            lock.lock()
            defer { lock.unlock() }
            return _shortDate.string(from: date)
        }
    }

    enum koreanDateTime {
        public static func date(from string: String) -> Date? {
            lock.lock()
            defer { lock.unlock() }
            return _koreanDateTime.date(from: string)
        }

        public static func string(from date: Date) -> String {
            lock.lock()
            defer { lock.unlock() }
            return _koreanDateTime.string(from: date)
        }
    }

    enum koreanDateOnly {
        public static func date(from string: String) -> Date? {
            lock.lock()
            defer { lock.unlock() }
            return _koreanDateOnly.date(from: string)
        }

        public static func string(from date: Date) -> String {
            lock.lock()
            defer { lock.unlock() }
            return _koreanDateOnly.string(from: date)
        }
    }

    enum koreanFullDate {
        public static func date(from string: String) -> Date? {
            lock.lock()
            defer { lock.unlock() }
            return _koreanFullDate.date(from: string)
        }

        public static func string(from date: Date) -> String {
            lock.lock()
            defer { lock.unlock() }
            return _koreanFullDate.string(from: date)
        }
    }
}
