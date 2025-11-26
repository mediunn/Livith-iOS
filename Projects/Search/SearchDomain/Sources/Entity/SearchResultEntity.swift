//
//  SearchResultEntity.swift
//  Search
//
//  Created by Youjin Lee on 11/27/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import Foundation

public struct SearchResultEntity {
    public let concerts: [ConcertEntity]
    public let cursor: (value: String, id: Int)?
    public let totalCount: Int

    public init(
        concerts: [ConcertEntity],
        cursor: (value: String, id: Int)?,
        totalCount: Int
    ) {
        self.concerts = concerts
        self.cursor = cursor
        self.totalCount = totalCount
    }
}
