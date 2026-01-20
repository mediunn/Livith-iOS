//
//  SearchResultEntity.swift
//  Domain
//
//  Created by 김진웅 on 1/21/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

public struct SearchResultEntity {
    public let concerts: [Concert]
    public let cursor: (value: String, id: Int)?
    public let totalCount: Int

    public init(
        concerts: [Concert],
        cursor: (value: String, id: Int)?,
        totalCount: Int
    ) {
        self.concerts = concerts
        self.cursor = cursor
        self.totalCount = totalCount
    }
}
