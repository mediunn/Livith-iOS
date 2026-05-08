//
//  InterestConcertDisplayText.swift
//  DisplaySupport
//
//  Created by 김진웅 on 4/30/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

import Domain
import LivithFoundation

public enum InterestConcertDisplayText {
    public static let unknownVenue = "장소 공개 예정"
    public static let unknownDateRange = "추후 발표"
    public static let unknownDaysLeft = "공연 예정"
    public static let unknownTicketingDate = "예매 오픈 예정"

    public static func title(for interestConcert: InterestConcert) -> String {
        let concert = interestConcert.concert

        guard let title = concert.title.nonEmpty else {
            return "\(concert.artist) 내한 예정"
        }

        return title
    }

    public static func venue(for interestConcert: InterestConcert) -> String {
        return interestConcert.concert.venue.nonEmpty ?? unknownVenue
    }

    public static func dateRange(for interestConcert: InterestConcert) -> String {
        let concert = interestConcert.concert

        guard let startDate = concert.startDate, let endDate = concert.endDate else {
            return unknownDateRange
        }

        return DateFormatter.formatDateRange(from: startDate, to: endDate)
    }

    public static func badge(for interestConcert: InterestConcert) -> String {
        let concert = interestConcert.concert

        guard concert.status != .ongoing else {
            return "공연 D-DAY"
        }

        guard concert.status == .upcoming else {
            return concert.status.filterText
        }

        guard let daysLeft = concert.daysLeft else {
            return unknownDaysLeft
        }

        guard daysLeft != 0 else {
            return "공연 D-DAY"
        }

        guard daysLeft > 0 else {
            return unknownDaysLeft
        }

        return "공연 D-\(daysLeft)"
    }

    public static func bottom(for interestConcert: InterestConcert) -> String {
        if interestConcert.concert.status == .ongoing {
            return "콘서트 진행중"
        }

        if interestConcert.concert.daysLeft == 0 {
            return "공연 진행 중"
        }

        let schedule = interestConcert.ticketingSchedule
        if let preSaleDate = schedule.preSaleDate {
            return "선예매 오픈 · \(ticketingDate(preSaleDate))"
        }

        guard let generalSaleDate = schedule.generalSaleDate else {
            return unknownTicketingDate
        }

        return "일반 예매 오픈 · \(ticketingDate(generalSaleDate))"
    }
}

private extension InterestConcertDisplayText {
    static func ticketingDate(_ date: Date) -> String {
        return DateFormatterService.string(from: date, type: .koreanDateTime)
    }
}

private extension Optional where Wrapped == String {
    var nonEmpty: String? {
        guard let value = self?.trimmingCharacters(in: .whitespacesAndNewlines), !value.isEmpty else {
            return nil
        }

        return value
    }
}
