//
//  Artist.swift
//  Concert
//
//  Created by Youjin Lee on 12/27/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import Foundation

import ConcertDomain

public struct Artist: Codable, Equatable {
    public let id: Int
    public let name: String
    public let debutYear: String
    public let category: String
    public let imageURL: String?
    public let detail: String
    public let keywords: [String]
    public let instagramURL: String?
}
