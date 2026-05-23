//
//  ConcertDisplayHelper.swift
//  DisplaySupport
//
//  Created by 김진웅 on 4/29/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

import Domain
import LivithFoundation

public enum ConcertDisplayHelper {
    public static let unknownVenue = "장소 공개 예정"
    public static let unknownDateRange = "추후 발표"
    public static let unknownDaysLeft = "공연 예정"
    public static let unknownTicketingDate = "예매 오픈 예정"

    public static func title(for concert: Concert) -> String {
        guard let title = concert.title.nonEmpty else {
            return "\(concert.artist) 내한 예정"
        }

        return title
    }

    public static func venue(for concert: Concert) -> String {
        return concert.venue.nonEmpty ?? unknownVenue
    }

    public static func dateRange(for concert: Concert) -> String {
        return dateRange(from: concert.startDate, to: concert.endDate)
    }

    public static func dateRange(from startDate: Date?, to endDate: Date?) -> String {
        guard let startDate, let endDate else {
            return unknownDateRange
        }

        return DateFormatter.formatDateRange(from: startDate, to: endDate)
    }

    public static func daysLeft(for concert: Concert) -> String {
        guard let daysLeft = concert.daysLeft else {
            return unknownDaysLeft
        }

        guard daysLeft != 0 else {
            return ConcertStatus.ongoing.statusChipText
        }

        guard daysLeft > 0 else {
            return ConcertStatus.completed.statusChipText
        }

        return "D-\(daysLeft)"
    }

    public static func statusBadge(for concert: Concert) -> String {
        guard concert.status == .upcoming else {
            return concert.status.statusChipText
        }

        return daysLeft(for: concert)
    }

    public static func ticketingDate(_ date: Date?) -> String {
        guard let date else {
            return unknownTicketingDate
        }

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
