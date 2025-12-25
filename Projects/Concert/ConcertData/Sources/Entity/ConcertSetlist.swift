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
    public let type: String
    public let startDate: String
    public let endDate: String
    public let status: String?
    public let venue: String
    public let artist: String
}
