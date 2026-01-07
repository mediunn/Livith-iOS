//
//  Setlist.swift
//  SetlistDomain
//
//  Created by Youjin Lee on 12/30/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import Foundation

public struct Setlist: Identifiable, Hashable {
    public let id: Int
    public let title: String
    public let imageURL: String?
    public let type: SetlistType
    public let status: String?
    public let startDate: Date
    public let endDate: Date
    public let venue: String
    public let artist: String

    public init(
        id: Int,
        title: String,
        imageURL: String?,
        type: SetlistType,
        status: String? = nil,
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
