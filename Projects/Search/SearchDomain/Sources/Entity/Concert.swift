//
//  Concert.swift
//  search
//
//  Created by Youjin Lee on 10/27/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import Foundation

public struct Concert: Hashable, Identifiable {
    public let id: Int
    public let title: String
    public let artist: String
    public let status: ConcertStatus
    public let daysLeft: Int
    public let startDate: String
    public let endDate: String
    public let posterURL: URL
    public let venue: String
    public let ticketingOffice: String?
    public let ticketingOfficeURL: URL?
    public let introduction: String
    public let label: String?
    
    public init(
        id: Int,
        title: String,
        artist: String,
        status: ConcertStatus,
        daysLeft: Int,
        startDate: String,
        endDate: String,
        posterURL: URL,
        venue: String,
        ticketSite: String?,
        ticketURL: URL?,
        introduction: String,
        label: String?
    ) {
        self.id = id
        self.title = title
        self.artist = artist
        self.status = status
        self.daysLeft = daysLeft
        self.startDate = startDate
        self.endDate = endDate
        self.posterURL = posterURL
        self.venue = venue
        self.ticketingOffice = ticketSite
        self.ticketingOfficeURL = ticketURL
        self.introduction = introduction
        self.label = label
    }
}
