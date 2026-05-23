//
//  InterestConcertDisplayHelper.swift
//  DisplaySupport
//
//  Created by 김진웅 on 4/30/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

import Domain
import LivithFoundation

public enum InterestConcertDisplayHelper {
    public static let unknownVenue = "장소 공개 예정"
    public static let unknownDateRange = "추후 발표"
    public static let unknownDaysLeft = "공연 예정"
    public static let unknownTicketingDate = "예매 오픈 예정"
    public static let ongoingConcert = "콘서트 진행중"

    public static func title(for interestConcert: InterestConcert) -> String {
        let concert = interestConcert.concert

        guard let title = concert.title, !title.isEmpty else {
            return "\(concert.artist) 내한 예정"
        }

        return title
    }

    public static func venue(for interestConcert: InterestConcert) -> String {
        guard let venue = interestConcert.concert.venue, !venue.isEmpty else {
            return unknownVenue
        }
        return venue
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
            return ongoingConcert
        }

        if isCurrentlyOngoing(interestConcert.concert) {
            return ongoingConcert
        }

        if interestConcert.concert.daysLeft == 0 {
            return ongoingConcert
        }

        let schedule = interestConcert.ticketingSchedule

        let upcomingDates = [
            schedule.preSaleDate.map { (date: $0, isPreSale: true) },
            schedule.generalSaleDate.map { (date: $0, isPreSale: false) }
        ]
        .compactMap { $0 }
        .filter { $0.date >= .now }

        if let earliest = upcomingDates.min(by: { $0.date < $1.date }) {
            let label = earliest.isPreSale ? "선예매 오픈" : "일반 예매 오픈"
            return "\(label) · \(ticketingDate(earliest.date))"
        }

        if let generalSaleDate = schedule.generalSaleDate {
            return "일반 예매 오픈 · \(ticketingDate(generalSaleDate))"
        }

        if let preSaleDate = schedule.preSaleDate {
            return "선예매 오픈 · \(ticketingDate(preSaleDate))"
        }

        return unknownTicketingDate
    }
}

private extension InterestConcertDisplayHelper {
    static func isCurrentlyOngoing(_ concert: Concert) -> Bool {
        guard let startDate = concert.startDate, let endDate = concert.endDate else {
            return false
        }
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let startDay = calendar.startOfDay(for: startDate)
        let endDay = calendar.startOfDay(for: endDate)
        return startDay <= today && today <= endDay
    }

    static func ticketingDate(_ date: Date) -> String {
        return DateFormatterService.string(from: date, type: .koreanDateTime)
    }
}
