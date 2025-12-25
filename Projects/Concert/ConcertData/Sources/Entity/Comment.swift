//
//  Comment.swift
//  Concert
//
//  Created by Youjin Lee on 12/25/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import Foundation

public struct Comment: Identifiable, Hashable {
    public let id: Int
    public let userID: Int
    public let nickname: String
    public let concertID: Int
    public let content: String
    public let createdAt: String
}
