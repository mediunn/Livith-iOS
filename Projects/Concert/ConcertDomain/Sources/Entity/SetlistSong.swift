//
//  SetlistSong.swift
//  ConcertDomain
//
//  Created by Youjin Lee on 12/25/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import Foundation

public struct SetlistSong: Identifiable, Hashable {
    public let id: Int
    public let title: String
    public let artist: String
    public let orderIndex: Int
}
