//
//  DateFormatType.swift
//  Core
//
//  Created by Youjin Lee on 1/4/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

// MARK: - DateFormatType

public enum DateFormatType: String {

    // MARK: Network (Mapper용) - en_US_POSIX, Asia/Seoul

    /// API 응답 ISO8601 형식: "2024-03-15T14:30:25.000Z"
    case iso8601 = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"

    /// 대시 구분 날짜: "2024-03-15"
    case dashDate = "yyyy-MM-dd"

    /// 점 구분 날짜: "2024.03.15"
    case dotDate = "yyyy.MM.dd"

    /// 점 구분 날짜+시간: "2024.03.15 14:30"
    case dotDateTime = "yyyy.MM.dd HH:mm"

    /// 짧은 날짜: "03.15"
    case shortDate = "MM.dd"

    // MARK: Display (View용) - ko_KR

    /// 한글 날짜+시간+AM/PM: "3/15(금) 2:30PM"
    case koreanDateTime = "M/d(E) h:mma"

    /// 한글 날짜+요일: "3/15(금)"
    case koreanDateOnly = "M/d(E)"

    /// 한글 연월일: "2024년 3월 15일"
    case koreanFullDate = "yyyy년 M월 d일"

    /// 시간만: "2:30"
    case timeOnly = "h:mm"

    /// AM/PM만: "PM"
    case ampm = "a"
}

// MARK: - Formatter Access

extension DateFormatType {
    var formatter: DateFormatter {
        switch self {
        case .iso8601: return Self._iso8601
        case .dashDate: return Self._dashDate
        case .dotDate: return Self._dotDate
        case .dotDateTime: return Self._dotDateTime
        case .shortDate: return Self._shortDate
        case .koreanDateTime: return Self._koreanDateTime
        case .koreanDateOnly: return Self._koreanDateOnly
        case .koreanFullDate: return Self._koreanFullDate
        case .timeOnly: return Self._timeOnly
        case .ampm: return Self._ampm
        }
    }

    var isNetworkFormat: Bool {
        switch self {
        case .iso8601, .dashDate, .dotDate, .dotDateTime, .shortDate:
            return true
        case .koreanDateTime, .koreanDateOnly, .koreanFullDate, .timeOnly, .ampm:
            return false
        }
    }
}

// MARK: - Cached Formatters

private extension DateFormatType {

    // MARK: Network 포맷 (en_US_POSIX, Asia/Seoul)

    static let _iso8601: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(identifier: "Asia/Seoul")
        return formatter
    }()

    static let _dashDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(identifier: "Asia/Seoul")
        return formatter
    }()

    static let _dotDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(identifier: "Asia/Seoul")
        return formatter
    }()

    static let _dotDateTime: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd HH:mm"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(identifier: "Asia/Seoul")
        return formatter
    }()

    static let _shortDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM.dd"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(identifier: "Asia/Seoul")
        return formatter
    }()

    // MARK: Display 포맷 (ko_KR)

    static let _koreanDateTime: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "M/d(E) h:mma"
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.amSymbol = "AM"
        formatter.pmSymbol = "PM"
        return formatter
    }()

    static let _koreanDateOnly: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "M/d(E)"
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter
    }()

    static let _koreanFullDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy년 M월 d일"
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter
    }()

    static let _timeOnly: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm"
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter
    }()

    static let _ampm: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "a"
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.amSymbol = "AM"
        formatter.pmSymbol = "PM"
        return formatter
    }()
}
