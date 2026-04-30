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

public struct InterestConcertPage: Hashable, Codable {
    public let concertList: [InterestConcert]
    public let nextCursor: InterestConcertPageCursor?

    public init(
        concertList: [InterestConcert],
        nextCursor: InterestConcertPageCursor?
    ) {
        self.concertList = concertList
        self.nextCursor = nextCursor
    }
}

public struct InterestConcertPageCursor: Hashable, Codable {
    public let date: Date
    public let id: Int

    public init(date: Date, id: Int) {
        self.date = date
        self.id = id
    }
}

public struct InterestConcertListQuery: Hashable {
    public let sort: InterestConcertSort
    public let pageSize: Int
    public let cursor: InterestConcertPageCursor?

    public init(
        sort: InterestConcertSort = .concert,
        pageSize: Int = 20,
        cursor: InterestConcertPageCursor? = nil
    ) {
        self.sort = sort
        self.pageSize = pageSize
        self.cursor = cursor
    }
}

public extension InterestConcertListQuery {
    static func homeSection(sort: InterestConcertSort = .concert) -> InterestConcertListQuery {
        InterestConcertListQuery(sort: sort, pageSize: 5)
    }
}

public enum InterestConcertSort: Hashable {
    case concert
    case ticketing
}
