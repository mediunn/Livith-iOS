//
//  Setlist.swift
//  Domain
//
//  Created by 김진웅 on 1/21/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

public struct Setlist: Identifiable, Hashable {
    public let id: Int
    public let title: String
    public let imageURL: String?
    public let type: SetlistType
    public let status: SetlistStatus?
    public let startDate: Date
    public let endDate: Date
    public let venue: String
    public let artist: String

    public init(
        id: Int,
        title: String,
        imageURL: String?,
        type: SetlistType,
        status: SetlistStatus?,
        startDate: Date,
        endDate: Date,
        venue: String,
        artist: String
    ) {
        self.id = id
        self.title = title
        self.imageURL = imageURL
        self.type = type
        self.status = status
        self.startDate = startDate
        self.endDate = endDate
        self.venue = venue
        self.artist = artist
    }
}
