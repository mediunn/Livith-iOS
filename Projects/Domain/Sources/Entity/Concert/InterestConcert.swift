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
    public let nextToken: (any NextToken)?

    public init(
        sort: InterestConcertSort? = nil,
        limit: Int? = nil,
        nextToken: (any NextToken)? = nil
    ) {
        self.sort = sort
        self.limit = limit
        self.nextToken = nextToken
    }
}

public extension InterestConcertListFilter {
    static func initialSelectionPage(
        limit: Int,
        nextToken: (any NextToken)? = nil
    ) -> InterestConcertListFilter {
        InterestConcertListFilter(limit: limit, nextToken: nextToken)
    }

    static func homeSection(sort: InterestConcertSort = .ticketing) -> InterestConcertListFilter {
        InterestConcertListFilter(sort: sort, limit: 5)
    }

    static func page(
        sort: InterestConcertSort,
        limit: Int,
        nextToken: (any NextToken)? = nil
    ) -> InterestConcertListFilter {
        InterestConcertListFilter(sort: sort, limit: limit, nextToken: nextToken)
    }
}

public enum InterestConcertSort: Hashable {
    case concert
    case ticketing
}
