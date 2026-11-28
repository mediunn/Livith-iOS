//
//  InterestConcert.swift
//  Domain
//
//  Created by 김진웅 on 4/29/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

public struct InterestConcert: Hashable, Identifiable, Codable {
    public var id: Int { concert.id }

    public let concert: Concert
    public let ticketingSchedule: InterestConcertTicketingSchedule

    public init(
        concert: Concert,
        ticketingSchedule: InterestConcertTicketingSchedule
    ) {
        self.concert = concert
        self.ticketingSchedule = ticketingSchedule
    }
}

public struct InterestConcertTicketingSchedule: Hashable, Codable {
    public let preSaleDate: Date?
    public let generalSaleDate: Date?

    public init(
        preSaleDate: Date?,
        generalSaleDate: Date?
    ) {
        self.preSaleDate = preSaleDate
        self.generalSaleDate = generalSaleDate
    }
}

public struct InterestConcertListFilter {
    public let sort: InterestConcertSort?
    public let limit: Int?
    public let position: (any PagePosition)?

    public init(
        sort: InterestConcertSort? = nil,
        limit: Int? = nil,
        position: (any PagePosition)? = nil
    ) {
        self.sort = sort
        self.limit = limit
        self.position = position
    }
}

public extension InterestConcertListFilter {
    static func initialSelectionPage(
        limit: Int,
        position: (any PagePosition)? = nil
    ) -> InterestConcertListFilter {
        InterestConcertListFilter(limit: limit, position: position)
    }

    static func homeSection(sort: InterestConcertSort = .ticketing) -> InterestConcertListFilter {
        InterestConcertListFilter(sort: sort, limit: 5)
    }

    static func page(
        sort: InterestConcertSort,
        limit: Int,
        position: (any PagePosition)? = nil
    ) -> InterestConcertListFilter {
        InterestConcertListFilter(sort: sort, limit: limit, position: position)
    }
}

public enum InterestConcertSort: Hashable {
    case concert
    case ticketing
}
