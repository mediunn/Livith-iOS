//
//  ConcertSetlist.swift
//  Concert
//
//  Created by Youjin Lee on 12/27/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import Foundation

public struct ConcertSetlist: Identifiable, Hashable {
    public let id: Int
    public let title: String
    public let imageURL: String?
    public let type: ConcertStatus
    public let startDate: Date
    public let endDate: Date
    public let status: SetlistType
    public let venue: String
    public let artist: String

    public init(
        id: Int,
        title: String,
        imageURL: String?,
        type: ConcertStatus,
        startDate: Date,
        endDate: Date,
        status: SetlistType,
        venue: String,
        artist: String
    ) {
        self.id = id
        self.title = title
        self.imageURL = imageURL
        self.type = type
        self.startDate = startDate
        self.endDate = endDate
        self.status = status
        self.venue = venue
        self.artist = artist
    }
}
