//
//  SearchResult.swift
//  Domain
//
//  Created by 김진웅 on 1/21/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

public struct SearchResult {
    public let concerts: [Concert]
    public let cursor: Int?
    public let totalCount: Int

    public init(
        concerts: [Concert],
        cursor: Int?,
        totalCount: Int
    ) {
        self.concerts = concerts
        self.cursor = cursor
        self.totalCount = totalCount
    }
}
