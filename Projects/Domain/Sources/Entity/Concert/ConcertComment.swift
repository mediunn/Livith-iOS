//
//  ConcertComment.swift
//  Domain
//
//  Created by 김진웅 on 1/21/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

public struct ConcertComment: Identifiable, Hashable {
    public let id: Int
    public let userID: Int
    public let writer: String
    public let content: String
    public let createdAt: Date

    public init(id: Int, userID: Int, writer: String, content: String, createdAt: Date) {
        self.id = id
        self.userID = userID
        self.writer = writer
        self.content = content
        self.createdAt = createdAt
    }
}
