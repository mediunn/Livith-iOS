//
//  ListResult.swift
//  Domain
//
//  Created by 김진웅 on 5/1/26.
//  Copyright © 2026 Livith. All rights reserved.
//

public struct ListResult<Item> {
    public let items: [Item]
    public let position: (any PagePosition)?

    public init(
        items: [Item],
        position: (any PagePosition)?
    ) {
        self.items = items
        self.position = position
    }
}

// MARK: - PagePosition

public protocol PagePosition: Sendable {}
