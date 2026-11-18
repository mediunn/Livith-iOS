//
//  ListResult.swift
//  Domain
//
//  Created by 김진웅 on 5/1/26.
//  Copyright © 2026 Livith. All rights reserved.
//

public struct ListResult<Item> {
    public let items: [Item]
    public let nextToken: (any NextToken)?

    public init(
        items: [Item],
        nextToken: (any NextToken)?
    ) {
        self.items = items
        self.nextToken = nextToken
    }
}

// MARK: - NextToken

public protocol NextToken: Sendable {}
